-- Testes da fundação: isolamento entre fazendas, papéis e exclusão lógica.
-- Rodar: npx supabase test db            (banco local, precisa de Docker)
--        npx supabase test db --remote   (projeto vinculado; tudo roda numa
--                                         transação e é desfeito no ROLLBACK)
begin;
create extension if not exists pgtap with schema extensions;
set local search_path = public, extensions;

select plan(20);

-- -----------------------------------------------------------------------------
-- Usuários de teste (criados como superusuário; o trigger cria os perfis)
-- -----------------------------------------------------------------------------
insert into auth.users (id, email, raw_user_meta_data) values
  ('a0000000-0000-4000-8000-000000000001', 'gestor.a@teste.invalid', '{"nome":"Gestor A"}'),
  ('b0000000-0000-4000-8000-000000000001', 'gestor.b@teste.invalid', '{"nome":"Gestor B"}'),
  ('a0000000-0000-4000-8000-000000000002', 'func.a@teste.invalid',   '{"nome":"Funcionário A"}'),
  ('c0000000-0000-4000-8000-000000000001', 'sem.vinculo@teste.invalid', '{"nome":"Sem vínculo"}');

select is(
  (select count(*)::int from public.perfis where id in (
    'a0000000-0000-4000-8000-000000000001',
    'b0000000-0000-4000-8000-000000000001',
    'a0000000-0000-4000-8000-000000000002',
    'c0000000-0000-4000-8000-000000000001')),
  4, 'trigger cria um perfil para cada usuário cadastrado');

select is(
  (select nome from public.perfis where id = 'a0000000-0000-4000-8000-000000000001'),
  'Gestor A', 'perfil recebe o nome enviado no cadastro');

-- -----------------------------------------------------------------------------
-- Gestor A cria conta e fazenda (ids gerados "no aparelho")
-- -----------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}', true);

insert into public.contas (id, nome)
  values ('a1000000-0000-4000-8000-000000000001', 'Conta A');

select lives_ok(
  $$ insert into public.fazendas (id, conta_id, nome, uf)
     values ('a2000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'Fazenda A', 'MG')
     returning id $$,
  'dono cria fazenda com INSERT ... RETURNING (como o supabase-js faz)');

select is(
  (select papel::text from public.vinculos
    where fazenda_id = 'a2000000-0000-4000-8000-000000000001'
      and usuario_id = 'a0000000-0000-4000-8000-000000000001'),
  'gestor', 'quem cria a fazenda vira gestor dela');

select lives_ok(
  $$ insert into public.vinculos (id, fazenda_id, usuario_id, papel)
     values ('a3000000-0000-4000-8000-000000000002', 'a2000000-0000-4000-8000-000000000001',
             'a0000000-0000-4000-8000-000000000002', 'funcionario') $$,
  'gestor adiciona funcionário na própria fazenda');

select throws_ok(
  $$ insert into public.vinculos (id, fazenda_id, usuario_id, papel)
     values ('a3000000-0000-4000-8000-000000000002', 'a2000000-0000-4000-8000-000000000001',
             'a0000000-0000-4000-8000-000000000002', 'funcionario') $$,
  '23505', null,
  'reenviar o mesmo UUID não duplica o registro (idempotência pela chave primária)');

-- -----------------------------------------------------------------------------
-- Gestor B: outra conta, outra fazenda — não pode ver nem mexer na A
-- -----------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"b0000000-0000-4000-8000-000000000001","role":"authenticated"}', true);

insert into public.contas (id, nome)
  values ('b1000000-0000-4000-8000-000000000001', 'Conta B');
insert into public.fazendas (id, conta_id, nome)
  values ('b2000000-0000-4000-8000-000000000001', 'b1000000-0000-4000-8000-000000000001', 'Fazenda B');

select is(
  (select count(*)::int from public.fazendas where id = 'a2000000-0000-4000-8000-000000000001'),
  0, 'gestor B não vê a fazenda A');

select is(
  (select count(*)::int from public.contas where id = 'a1000000-0000-4000-8000-000000000001'),
  0, 'gestor B não vê a conta A');

select is(
  (select count(*)::int from public.vinculos where fazenda_id = 'a2000000-0000-4000-8000-000000000001'),
  0, 'gestor B não vê os vínculos da fazenda A');

select throws_ok(
  $$ insert into public.vinculos (fazenda_id, usuario_id, papel)
     values ('a2000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'gestor') $$,
  '42501', null, 'gestor B não consegue se colocar como gestor da fazenda A');

select throws_ok(
  $$ insert into public.fazendas (conta_id, nome)
     values ('a1000000-0000-4000-8000-000000000001', 'Invasora') $$,
  '42501', null, 'gestor B não cria fazenda na conta A');

select throws_ok(
  $$ insert into public.vinculos (fazenda_id, usuario_id, papel)
     values ('b2000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', 'funcionario') $$,
  'P0001', null, 'funcionário da fazenda A não pode ser vinculado a outra fazenda (D-03)');

-- -----------------------------------------------------------------------------
-- Funcionário A: lê a fazenda dele, não gerencia usuários nem aparelhos
-- -----------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}', true);

select is(
  (select count(*)::int from public.fazendas),
  1, 'funcionário vê só a fazenda em que trabalha');

select throws_ok(
  $$ insert into public.vinculos (fazenda_id, usuario_id, papel)
     values ('a2000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000001', 'funcionario') $$,
  '42501', null, 'funcionário não adiciona usuários');

select lives_ok(
  $$ insert into public.aparelhos (id, fazenda_id, nome)
     values ('a4000000-0000-4000-8000-000000000001', 'a2000000-0000-4000-8000-000000000001', 'Celular do curral') $$,
  'funcionário registra o próprio aparelho na sua fazenda');

update public.aparelhos set revogado_em = now()
  where id = 'a4000000-0000-4000-8000-000000000001';

select is(
  (select revogado_em from public.aparelhos where id = 'a4000000-0000-4000-8000-000000000001'),
  null, 'funcionário não consegue revogar aparelho');

-- -----------------------------------------------------------------------------
-- Gestor A: exclusão física bloqueada; vê o aparelho do funcionário
-- -----------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}', true);

delete from public.fazendas where id = 'a2000000-0000-4000-8000-000000000001';

select is(
  (select count(*)::int from public.fazendas where id = 'a2000000-0000-4000-8000-000000000001'),
  1, 'DELETE não apaga a fazenda (só exclusão lógica)');

select is(
  (select count(*)::int from public.aparelhos where fazenda_id = 'a2000000-0000-4000-8000-000000000001'),
  1, 'gestor vê os aparelhos da fazenda dele');

-- -----------------------------------------------------------------------------
-- Visitante sem login
-- -----------------------------------------------------------------------------
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);

select is(
  (select count(*)::int from public.fazendas), 0, 'visitante sem login não vê fazendas');

select is(
  (select count(*)::int from public.perfis), 0, 'visitante sem login não vê perfis');

select * from finish();
rollback;
