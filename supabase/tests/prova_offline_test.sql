-- Testes da prova técnica do offline: envio idempotente, conflito de edição (D-22),
-- permissões (D-17), isolamento entre fazendas e exclusão lógica.
-- Tudo roda numa transação desfeita no final.
begin;
create extension if not exists pgtap with schema extensions;
set local search_path = public, extensions;

select plan(30);

-- -----------------------------------------------------------------------------
-- Cenário (montado como superusuário)
-- -----------------------------------------------------------------------------
insert into auth.users (id, email, raw_user_meta_data) values
  ('a0000000-0000-4000-8000-000000000001', 'gestor.a@teste.invalid', '{"nome":"Gestor A"}'),
  ('a0000000-0000-4000-8000-000000000002', 'func.a@teste.invalid',   '{"nome":"Funcionário A"}'),
  ('b0000000-0000-4000-8000-000000000001', 'gestor.b@teste.invalid', '{"nome":"Gestor B"}');

insert into public.contas (id, nome, dono_id) values
  ('a1000000-0000-4000-8000-000000000001', 'Conta A', 'a0000000-0000-4000-8000-000000000001'),
  ('b1000000-0000-4000-8000-000000000001', 'Conta B', 'b0000000-0000-4000-8000-000000000001');
insert into public.fazendas (id, conta_id, nome) values
  ('a2000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'Fazenda A'),
  ('b2000000-0000-4000-8000-000000000001', 'b1000000-0000-4000-8000-000000000001', 'Fazenda B');
insert into public.vinculos (fazenda_id, usuario_id, papel) values
  ('a2000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'gestor'),
  ('a2000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', 'funcionario'),
  ('b2000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'gestor');

select ok(
  (select count(*) = 2 from pg_publication_tables
    where pubname = 'powersync' and schemaname = 'public'
      and tablename in ('teste_animais', 'vinculos')),
  'publicação "powersync" contém teste_animais e vinculos');

select ok(
  (select rolreplication and rolbypassrls from pg_roles where rolname = 'powersync_role'),
  'powersync_role existe com REPLICATION e BYPASSRLS');

-- -----------------------------------------------------------------------------
-- Gestor A: cadastro idempotente
-- -----------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}', true);

select is(
  sincronizar_teste_animal('PUT', 'a5000000-0000-4000-8000-000000000001',
    '{"fazenda_id":"a2000000-0000-4000-8000-000000000001","brinco":"T-001","nome":"Mimosa","versao":1,"criado_em":"2026-11-17T10:00:00.000Z"}') ->> 'resultado',
  'aplicado', 'cadastro novo é aplicado');

select is(
  sincronizar_teste_animal('PUT', 'a5000000-0000-4000-8000-000000000001',
    '{"fazenda_id":"a2000000-0000-4000-8000-000000000001","brinco":"T-001","nome":"Mimosa","versao":1,"criado_em":"2026-11-17T10:00:00.000Z"}') ->> 'resultado',
  'ja_aplicado', 'reenviar o mesmo cadastro responde ja_aplicado');

select is(
  (select count(*)::int from teste_animais where id = 'a5000000-0000-4000-8000-000000000001'),
  1, 'reenvio não duplica o animal (idempotência)');

select is(
  (select criado_em from teste_animais where id = 'a5000000-0000-4000-8000-000000000001'),
  '2026-11-17T10:00:00Z'::timestamptz, 'criado_em guarda a hora do aparelho');

select is(
  (select criado_por from teste_animais where id = 'a5000000-0000-4000-8000-000000000001'),
  'a0000000-0000-4000-8000-000000000001'::uuid, 'criado_por é quem enviou');

-- -----------------------------------------------------------------------------
-- Gestor A: edição com controle de versão (D-22)
-- -----------------------------------------------------------------------------
select is(
  sincronizar_teste_animal('PATCH', 'a5000000-0000-4000-8000-000000000001',
    '{"nome":"Mimosa II","versao":2}') ->> 'resultado',
  'aplicado', 'edição com versao = atual + 1 é aplicada');

select is(
  sincronizar_teste_animal('PATCH', 'a5000000-0000-4000-8000-000000000001',
    '{"nome":"Mimosa II","versao":2}') ->> 'resultado',
  'ja_aplicado', 'reenviar a mesma edição responde ja_aplicado');

select is(
  (select versao from teste_animais where id = 'a5000000-0000-4000-8000-000000000001'),
  2, 'reenvio da edição não sobe a versão de novo');

-- Outro aparelho, que também partiu da versão 1, envia outra edição.
select is(
  sincronizar_teste_animal('PATCH', 'a5000000-0000-4000-8000-000000000001',
    '{"nome":"Estrela","versao":2}') ->> 'resultado',
  'conflito', 'edição feita sobre versão antiga vira conflito');

select is(
  (select nome from teste_animais where id = 'a5000000-0000-4000-8000-000000000001'),
  'Mimosa II', 'conflito não sobrescreve o servidor');

select is(
  (select dados_aparelho ->> 'nome' from pendencias_sincronizacao
    where registro_id = 'a5000000-0000-4000-8000-000000000001' and tipo = 'conflito_edicao'),
  'Estrela', 'a versão do aparelho fica guardada na pendência (nada se perde)');

select is(
  (select dados_servidor ->> 'nome' from pendencias_sincronizacao
    where registro_id = 'a5000000-0000-4000-8000-000000000001' and tipo = 'conflito_edicao'),
  'Mimosa II', 'a versão do servidor também fica guardada na pendência');

select is(
  sincronizar_teste_animal('PATCH', 'a5000000-0000-4000-8000-000000000001',
    '{"nome":"Estrela","versao":2}') ->> 'resultado',
  'conflito', 'reenviar a edição em conflito continua respondendo conflito');

select is(
  (select count(*)::int from pendencias_sincronizacao
    where registro_id = 'a5000000-0000-4000-8000-000000000001' and tipo = 'conflito_edicao'),
  1, 'reenvio do conflito não duplica a pendência');

select is(
  sincronizar_teste_animal('PATCH', 'a5000000-0000-4000-8000-000000000001',
    '{"nome":"Sem versão"}') ->> 'motivo',
  'versao_ausente', 'edição sem versao é recusada e registrada');

select is(
  sincronizar_teste_animal('PATCH', 'a5000000-0000-4000-8000-0000000000ff',
    '{"nome":"Fantasma","versao":2}') ->> 'motivo',
  'registro_inexistente', 'edição de animal que o servidor não tem é recusada e registrada');

-- -----------------------------------------------------------------------------
-- Funcionário A: cadastra (D-17), mas não edita nem apaga
-- -----------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}', true);

select is(
  sincronizar_teste_animal('PUT', 'a5000000-0000-4000-8000-000000000002',
    '{"fazenda_id":"a2000000-0000-4000-8000-000000000001","brinco":"T-002","nome":"Pintada","versao":1}') ->> 'resultado',
  'aplicado', 'funcionário cadastra animal na sua fazenda');

select is(
  sincronizar_teste_animal('PATCH', 'a5000000-0000-4000-8000-000000000001',
    '{"nome":"Edição do funcionário","versao":3}') ->> 'motivo',
  'sem_permissao', 'edição do funcionário é recusada e registrada (D-17)');

update teste_animais set nome = 'Direto na tabela' where id = 'a5000000-0000-4000-8000-000000000001';

select is(
  (select nome from teste_animais where id = 'a5000000-0000-4000-8000-000000000001'),
  'Mimosa II', 'funcionário também não edita direto na tabela (RLS)');

select is(
  (select count(*)::int from pendencias_sincronizacao),
  1, 'funcionário vê só a própria pendência');

-- -----------------------------------------------------------------------------
-- Gestor B: outra fazenda
-- -----------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"b0000000-0000-4000-8000-000000000001","role":"authenticated"}', true);

select is(
  (select count(*)::int from teste_animais), 0, 'gestor B não vê animais da fazenda A');

select is(
  sincronizar_teste_animal('PUT', 'b5000000-0000-4000-8000-000000000001',
    '{"fazenda_id":"a2000000-0000-4000-8000-000000000001","brinco":"X","versao":1}') ->> 'motivo',
  'fazenda_sem_acesso', 'gestor B não cadastra na fazenda A');

select is(
  sincronizar_teste_animal('PATCH', 'a5000000-0000-4000-8000-000000000001',
    '{"nome":"Invasão","versao":3}') ->> 'motivo',
  'fazenda_sem_acesso', 'gestor B não edita animal da fazenda A');

-- -----------------------------------------------------------------------------
-- Gestor A: pendências da fazenda, exclusão lógica
-- -----------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}', true);

select is(
  (select count(*)::int from pendencias_sincronizacao
    where fazenda_id = 'a2000000-0000-4000-8000-000000000001'),
  3, 'gestor A vê as pendências da fazenda dele (conflito, versao_ausente, funcionário)');

select is(
  sincronizar_teste_animal('DELETE', 'a5000000-0000-4000-8000-000000000002', null) ->> 'resultado',
  'aplicado', 'exclusão pelo gestor é aplicada');

select ok(
  (select apagado_em is not null from teste_animais where id = 'a5000000-0000-4000-8000-000000000002'),
  'exclusão é lógica: o animal continua no banco com apagado_em');

delete from teste_animais where id = 'a5000000-0000-4000-8000-000000000001';

select is(
  (select count(*)::int from teste_animais where id = 'a5000000-0000-4000-8000-000000000001'),
  1, 'DELETE direto na tabela não apaga');

-- -----------------------------------------------------------------------------
-- Sem login
-- -----------------------------------------------------------------------------
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);

select throws_ok(
  $$ select public.sincronizar_teste_animal('PUT', 'c5000000-0000-4000-8000-000000000001',
       '{"fazenda_id":"a2000000-0000-4000-8000-000000000001","versao":1}') $$,
  '42501', null, 'visitante sem login não consegue chamar o envio');

select * from finish();
rollback;
