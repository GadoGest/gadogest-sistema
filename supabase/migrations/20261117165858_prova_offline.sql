-- =============================================================================
-- GadoGest — Prova técnica do offline (Etapa 0, Parte B — D-33)
-- =============================================================================
-- * teste_animais: espelho da tabela local do app (apps/mobile/src/banco/esquema.ts).
-- * pendencias_sincronizacao: tudo o que o servidor não pôde aplicar fica guardado
--   para o gestor decidir (D-22, D-06). Nada é perdido em silêncio (CLAUDE.md §6.8).
-- * sincronizar_teste_animal(): porta única de envio do app (uploadData do PowerSync).
--   Idempotente e sem erro por regra de negócio (um erro travaria a fila do aparelho).
-- * powersync_role + publicação "powersync": leitura para o PowerSync replicar.
--
-- Contrato com o app (D-36 em docs/DECISOES.md):
--   - Para cada item da fila: rpc('sincronizar_teste_animal',
--       { p_operacao: op.op, p_id: op.id, p_dados: op.opData ?? {} })
--   - Toda edição sobe "versao" em 1 no aparelho (versao nova = versao lida + 1).
--   - Resposta: { resultado: 'aplicado' | 'ja_aplicado' | 'conflito' | 'rejeitado', ... }.
--     Qualquer uma delas significa "processado": o app pode tirar o item da fila.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Tabela da prova
-- -----------------------------------------------------------------------------
create table public.teste_animais (
  id            uuid primary key,                -- gerado no aparelho
  fazenda_id    uuid not null references public.fazendas (id),
  brinco        text,
  nome          text,
  versao        integer not null default 1 check (versao >= 1),
  criado_por    uuid references public.perfis (id) default auth.uid(),
  criado_em     timestamptz not null default now(),   -- hora do aparelho
  atualizado_em timestamptz not null default now(),   -- hora do servidor
  apagado_em    timestamptz
);
create index teste_animais_fazenda_id_idx on public.teste_animais (fazenda_id);
comment on table public.teste_animais is 'Tabela provisória da prova técnica do offline (Etapa 0). Será substituída pela tabela de animais da Etapa 2.';

-- -----------------------------------------------------------------------------
-- Pendências de sincronização
-- -----------------------------------------------------------------------------
create table public.pendencias_sincronizacao (
  id             uuid primary key default gen_random_uuid(),
  fazenda_id     uuid references public.fazendas (id),  -- nulo se a fazenda não é acessível
  tabela         text not null,
  registro_id    uuid not null,
  tipo           text not null check (tipo in (
                   'conflito_edicao',      -- D-22: outro aparelho editou antes
                   'sem_permissao',        -- D-17: funcionário tentou editar/apagar
                   'fazenda_sem_acesso',   -- usuário sem vínculo com a fazenda
                   'registro_inexistente', -- edição de registro que o servidor não tem
                   'versao_ausente'        -- edição sem o campo "versao"
                 )),
  operacao       text not null,
  dados_aparelho jsonb not null,
  dados_servidor jsonb,
  enviado_por    uuid references public.perfis (id),
  criado_em      timestamptz not null default now(),
  resolvido_em   timestamptz,
  resolvido_por  uuid references public.perfis (id),
  resolucao      text
);
create index pendencias_sincronizacao_fazenda_id_idx on public.pendencias_sincronizacao (fazenda_id);
create index pendencias_sincronizacao_registro_id_idx on public.pendencias_sincronizacao (registro_id);
-- Reenvio do mesmo item da fila não cria pendência repetida.
create unique index pendencias_sincronizacao_reenvio_uq
  on public.pendencias_sincronizacao (registro_id, tipo, operacao, enviado_por, md5(dados_aparelho::text))
  where resolvido_em is null;
comment on table public.pendencias_sincronizacao is 'Envios do aparelho que o servidor não aplicou. O gestor resolve. Registro "em conflito" = tem pendência aberta (calculado, não armazenado).';

-- -----------------------------------------------------------------------------
-- RLS
-- -----------------------------------------------------------------------------
alter table public.teste_animais enable row level security;
alter table public.pendencias_sincronizacao enable row level security;

create policy "teste_animais: membros da fazenda leem"
  on public.teste_animais for select to authenticated
  using (privado.tem_acesso_fazenda(fazenda_id));

create policy "teste_animais: membros da fazenda cadastram"
  on public.teste_animais for insert to authenticated
  with check (privado.tem_acesso_fazenda(fazenda_id) and criado_por = (select auth.uid()));

create policy "teste_animais: gestor edita (D-17)"
  on public.teste_animais for update to authenticated
  using (privado.eh_gestor_fazenda(fazenda_id))
  with check (privado.eh_gestor_fazenda(fazenda_id));

create policy "pendencias: gestor vê as da fazenda; cada um vê as próprias"
  on public.pendencias_sincronizacao for select to authenticated
  using (
    enviado_por = (select auth.uid())
    or (fazenda_id is not null and privado.eh_gestor_fazenda(fazenda_id))
  );

create policy "pendencias: gestor resolve"
  on public.pendencias_sincronizacao for update to authenticated
  using (fazenda_id is not null and privado.eh_gestor_fazenda(fazenda_id))
  with check (fazenda_id is not null and privado.eh_gestor_fazenda(fazenda_id));
-- Sem política de INSERT: pendências só nascem pela função de envio.

-- -----------------------------------------------------------------------------
-- Registro de pendência (sem duplicar em reenvios)
-- -----------------------------------------------------------------------------
create function privado.registrar_pendencia(
  p_fazenda_id uuid,
  p_tabela text,
  p_registro_id uuid,
  p_tipo text,
  p_operacao text,
  p_dados_aparelho jsonb,
  p_dados_servidor jsonb
)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.pendencias_sincronizacao
    (fazenda_id, tabela, registro_id, tipo, operacao, dados_aparelho, dados_servidor, enviado_por)
  values
    (p_fazenda_id, p_tabela, p_registro_id, p_tipo, p_operacao, p_dados_aparelho, p_dados_servidor, (select auth.uid()))
  on conflict do nothing;
$$;
revoke all on function privado.registrar_pendencia(uuid, text, uuid, text, text, jsonb, jsonb) from public;

-- -----------------------------------------------------------------------------
-- Envio do app: uma chamada por item da fila do PowerSync (PUT, PATCH, DELETE)
-- -----------------------------------------------------------------------------
create function public.sincronizar_teste_animal(p_operacao text, p_id uuid, p_dados jsonb default '{}'::jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := (select auth.uid());
  v_dados   jsonb := coalesce(p_dados, '{}'::jsonb);
  v_atual   public.teste_animais;
  v_fazenda uuid;
  v_versao  integer;
  v_igual   boolean;
begin
  if v_uid is null then
    -- Sem login não há como processar; o app deve tentar de novo depois de entrar.
    raise exception 'Envio sem usuário autenticado.' using errcode = '28000';
  end if;

  -- ---------------- Cadastro (PUT) ----------------
  if p_operacao = 'PUT' then
    if exists (select 1 from public.teste_animais where id = p_id) then
      return jsonb_build_object('resultado', 'ja_aplicado', 'id', p_id);
    end if;

    v_fazenda := nullif(v_dados ->> 'fazenda_id', '')::uuid;
    if v_fazenda is null or not privado.tem_acesso_fazenda(v_fazenda) then
      perform privado.registrar_pendencia(null, 'teste_animais', p_id, 'fazenda_sem_acesso', p_operacao, v_dados, null);
      return jsonb_build_object('resultado', 'rejeitado', 'motivo', 'fazenda_sem_acesso', 'id', p_id);
    end if;

    insert into public.teste_animais
      (id, fazenda_id, brinco, nome, versao, criado_por, criado_em, atualizado_em, apagado_em)
    values (
      p_id,
      v_fazenda,
      v_dados ->> 'brinco',
      v_dados ->> 'nome',
      coalesce((v_dados ->> 'versao')::integer, 1),
      v_uid,
      coalesce((v_dados ->> 'criado_em')::timestamptz, now()),
      now(),
      (v_dados ->> 'apagado_em')::timestamptz
    )
    on conflict (id) do nothing;

    return jsonb_build_object('resultado', 'aplicado', 'id', p_id);
  end if;

  if p_operacao not in ('PATCH', 'DELETE') then
    raise exception 'Operação desconhecida: %', p_operacao using errcode = '22023';
  end if;

  -- ---------------- Edição (PATCH) e exclusão (DELETE) ----------------
  select * into v_atual from public.teste_animais where id = p_id for update;

  if not found then
    perform privado.registrar_pendencia(null, 'teste_animais', p_id, 'registro_inexistente', p_operacao, v_dados, null);
    return jsonb_build_object('resultado', 'rejeitado', 'motivo', 'registro_inexistente', 'id', p_id);
  end if;

  if not privado.tem_acesso_fazenda(v_atual.fazenda_id) then
    perform privado.registrar_pendencia(null, 'teste_animais', p_id, 'fazenda_sem_acesso', p_operacao, v_dados, null);
    return jsonb_build_object('resultado', 'rejeitado', 'motivo', 'fazenda_sem_acesso', 'id', p_id);
  end if;

  if not privado.eh_gestor_fazenda(v_atual.fazenda_id) then
    perform privado.registrar_pendencia(v_atual.fazenda_id, 'teste_animais', p_id, 'sem_permissao', p_operacao, v_dados, to_jsonb(v_atual));
    return jsonb_build_object('resultado', 'rejeitado', 'motivo', 'sem_permissao', 'id', p_id);
  end if;

  -- Exclusão física nunca acontece: vira exclusão lógica.
  if p_operacao = 'DELETE' then
    if v_atual.apagado_em is null then
      update public.teste_animais
         set apagado_em = now(), versao = versao + 1, atualizado_em = now()
       where id = p_id;
      return jsonb_build_object('resultado', 'aplicado', 'id', p_id);
    end if;
    return jsonb_build_object('resultado', 'ja_aplicado', 'id', p_id);
  end if;

  -- PATCH: controle de versão (D-22)
  v_versao := (v_dados ->> 'versao')::integer;
  if v_versao is null then
    perform privado.registrar_pendencia(v_atual.fazenda_id, 'teste_animais', p_id, 'versao_ausente', p_operacao, v_dados, to_jsonb(v_atual));
    return jsonb_build_object('resultado', 'rejeitado', 'motivo', 'versao_ausente', 'id', p_id);
  end if;

  -- Os campos enviados já estão iguais no servidor? (reenvio de uma edição aplicada)
  v_igual :=
        (not v_dados ? 'brinco'     or (v_dados ->> 'brinco') is not distinct from v_atual.brinco)
    and (not v_dados ? 'nome'       or (v_dados ->> 'nome')   is not distinct from v_atual.nome)
    and (not v_dados ? 'apagado_em' or (v_dados ->> 'apagado_em')::timestamptz is not distinct from v_atual.apagado_em);

  if v_versao = v_atual.versao and v_igual then
    return jsonb_build_object('resultado', 'ja_aplicado', 'id', p_id, 'versao', v_atual.versao);
  end if;

  if v_versao <> v_atual.versao + 1 then
    -- Outro aparelho editou antes: mantém as duas versões; o gestor decide.
    perform privado.registrar_pendencia(v_atual.fazenda_id, 'teste_animais', p_id, 'conflito_edicao', p_operacao, v_dados, to_jsonb(v_atual));
    return jsonb_build_object('resultado', 'conflito', 'id', p_id, 'versao_servidor', v_atual.versao);
  end if;

  -- fazenda_id, criado_por e criado_em não mudam por edição.
  update public.teste_animais
     set brinco        = case when v_dados ? 'brinco' then v_dados ->> 'brinco' else brinco end,
         nome          = case when v_dados ? 'nome' then v_dados ->> 'nome' else nome end,
         apagado_em    = case when v_dados ? 'apagado_em' then (v_dados ->> 'apagado_em')::timestamptz else apagado_em end,
         versao        = v_versao,
         atualizado_em = now()
   where id = p_id;

  return jsonb_build_object('resultado', 'aplicado', 'id', p_id, 'versao', v_versao);
end;
$$;

revoke all on function public.sincronizar_teste_animal(text, uuid, jsonb) from public, anon;
grant execute on function public.sincronizar_teste_animal(text, uuid, jsonb) to authenticated;
comment on function public.sincronizar_teste_animal(text, uuid, jsonb) is
  'Envio do app (uploadData do PowerSync). Idempotente; conflitos e recusas viram pendências, nunca erro.';

-- -----------------------------------------------------------------------------
-- PowerSync: usuário de replicação (somente leitura) e publicação
-- A SENHA não fica no repositório: definir no SQL Editor do Supabase com
--   alter role powersync_role with password '...';
-- -----------------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'powersync_role') then
    create role powersync_role with replication bypassrls login;
  end if;
end;
$$;

grant usage on schema public to powersync_role;
grant select on public.teste_animais, public.vinculos to powersync_role;

-- O PowerSync exige o nome "powersync". vinculos entra porque a regra de
-- sincronização usa os vínculos para saber quais fazendas cada usuário recebe.
create publication powersync for table public.teste_animais, public.vinculos;
