-- =============================================================================
-- GadoGest — Fundação (Etapa 1): contas, fazendas, perfis, vínculos e aparelhos
-- =============================================================================
-- Princípios (CLAUDE.md §6 e §8):
--   * IDs em UUID; o aparelho pode gerar o próprio id (o default só vale quando
--     o registro nasce no servidor). Reenviar o mesmo id não duplica (PK).
--   * criado_em / atualizado_em / apagado_em em timestamptz (UTC).
--   * Exclusão lógica: nenhuma tabela tem política de DELETE; "apagar" é
--     preencher apagado_em. Restaurar é limpar apagado_em (ação explícita).
--   * Isolamento por fazenda aplicado no banco (RLS), não na interface.
--
-- Matriz de permissões PROVISÓRIA (Q-20 ainda aberta, ver docs/DECISOES.md D-14):
--   * Dono da conta: cria fazendas na conta e vira gestor delas automaticamente.
--   * Gestor: tudo na(s) fazenda(s) em que é gestor (inclusive usuários e aparelhos).
--   * Funcionário: lê os dados da fazenda dele, registra o próprio aparelho;
--     não gerencia usuários nem aparelhos.
--   * Funcionário só pode ter vínculo ativo com UMA fazenda (D-03).
-- =============================================================================

-- Funções auxiliares ficam num schema que NÃO é exposto pela API (PostgREST).
create schema if not exists privado;
revoke all on schema privado from public;
grant usage on schema privado to authenticated;

create type public.papel_vinculo as enum ('gestor', 'funcionario');

-- -----------------------------------------------------------------------------
-- atualizado_em automático
-- -----------------------------------------------------------------------------
create function privado.definir_atualizado_em()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.atualizado_em := now();
  return new;
end;
$$;

-- -----------------------------------------------------------------------------
-- Tabelas
-- -----------------------------------------------------------------------------

-- Perfil público de cada usuário do Supabase Auth (criado por trigger no cadastro).
create table public.perfis (
  id            uuid primary key references auth.users (id),
  nome          text not null default '',
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);
comment on table public.perfis is 'Dados públicos do usuário (1:1 com auth.users). Criado automaticamente no cadastro.';

-- Conta = cliente (assinatura). Regras de cobrança ainda pendentes (Q-05, Q-06, Q-09).
create table public.contas (
  id            uuid primary key default gen_random_uuid(),
  nome          text not null check (length(trim(nome)) > 0),
  dono_id       uuid not null default auth.uid() references public.perfis (id),
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  apagado_em    timestamptz
);
create index contas_dono_id_idx on public.contas (dono_id);
comment on table public.contas is 'Cliente do GadoGest. Uma conta pode ter várias fazendas.';

create table public.fazendas (
  id            uuid primary key default gen_random_uuid(),
  conta_id      uuid not null references public.contas (id),
  nome          text not null check (length(trim(nome)) > 0),
  municipio     text,
  uf            char(2) check (uf is null or uf ~ '^[A-Z]{2}$'),
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  apagado_em    timestamptz
);
create index fazendas_conta_id_idx on public.fazendas (conta_id);

-- Vínculo usuário ↔ fazenda, com o papel do usuário naquela fazenda.
create table public.vinculos (
  id            uuid primary key default gen_random_uuid(),
  fazenda_id    uuid not null references public.fazendas (id),
  usuario_id    uuid not null references public.perfis (id),
  papel         public.papel_vinculo not null,
  criado_por    uuid default auth.uid() references public.perfis (id),
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  apagado_em    timestamptz
);
-- Um vínculo ativo por usuário e fazenda.
create unique index vinculos_usuario_fazenda_ativo_uq
  on public.vinculos (usuario_id, fazenda_id) where apagado_em is null;
create index vinculos_fazenda_id_idx on public.vinculos (fazenda_id);

-- Aparelhos autorizados. Licença offline (T-17) e limite de aparelhos (Q-06) virão na Etapa 6.
create table public.aparelhos (
  id            uuid primary key default gen_random_uuid(),
  fazenda_id    uuid not null references public.fazendas (id),
  usuario_id    uuid not null default auth.uid() references public.perfis (id),
  nome          text not null check (length(trim(nome)) > 0),
  plataforma    text not null default 'android' check (plataforma in ('android', 'ios', 'web')),
  revogado_em   timestamptz,
  revogado_por  uuid references public.perfis (id),
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  apagado_em    timestamptz
);
create index aparelhos_fazenda_id_idx on public.aparelhos (fazenda_id);
create index aparelhos_usuario_id_idx on public.aparelhos (usuario_id);

-- Triggers de atualizado_em
create trigger definir_atualizado_em before update on public.perfis
  for each row execute function privado.definir_atualizado_em();
create trigger definir_atualizado_em before update on public.contas
  for each row execute function privado.definir_atualizado_em();
create trigger definir_atualizado_em before update on public.fazendas
  for each row execute function privado.definir_atualizado_em();
create trigger definir_atualizado_em before update on public.vinculos
  for each row execute function privado.definir_atualizado_em();
create trigger definir_atualizado_em before update on public.aparelhos
  for each row execute function privado.definir_atualizado_em();

-- -----------------------------------------------------------------------------
-- Funções de permissão (SECURITY DEFINER para não depender do RLS das próprias
-- tabelas e evitar recursão nas políticas).
-- -----------------------------------------------------------------------------
create function privado.tem_acesso_fazenda(p_fazenda_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.vinculos v
    where v.fazenda_id = p_fazenda_id
      and v.usuario_id = (select auth.uid())
      and v.apagado_em is null
  );
$$;

create function privado.eh_gestor_fazenda(p_fazenda_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.vinculos v
    where v.fazenda_id = p_fazenda_id
      and v.usuario_id = (select auth.uid())
      and v.papel = 'gestor'
      and v.apagado_em is null
  );
$$;

create function privado.eh_dono_conta(p_conta_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.contas c
    where c.id = p_conta_id
      and c.dono_id = (select auth.uid())
  );
$$;

-- Usuário tem vínculo ativo em alguma fazenda da conta?
create function privado.tem_acesso_conta(p_conta_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.vinculos v
    join public.fazendas f on f.id = v.fazenda_id
    where f.conta_id = p_conta_id
      and v.usuario_id = (select auth.uid())
      and v.apagado_em is null
  );
$$;

-- O usuário logado e p_usuario_id trabalham numa mesma fazenda?
create function privado.compartilha_fazenda(p_usuario_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.vinculos meu
    join public.vinculos outro on outro.fazenda_id = meu.fazenda_id
    where meu.usuario_id = (select auth.uid())
      and outro.usuario_id = p_usuario_id
      and meu.apagado_em is null
      and outro.apagado_em is null
  );
$$;

revoke all on all functions in schema privado from public;
grant execute on function
  privado.tem_acesso_fazenda(uuid),
  privado.eh_gestor_fazenda(uuid),
  privado.eh_dono_conta(uuid),
  privado.tem_acesso_conta(uuid),
  privado.compartilha_fazenda(uuid)
to authenticated;

-- -----------------------------------------------------------------------------
-- Regras automáticas
-- -----------------------------------------------------------------------------

-- Cria o perfil quando um usuário se cadastra no Supabase Auth.
-- O nome vem de options.data.nome no signUp (supabase-js).
create function privado.criar_perfil()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.perfis (id, nome)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'nome', ''));
  return new;
end;
$$;

create trigger criar_perfil after insert on auth.users
  for each row execute function privado.criar_perfil();

-- Quem cria a fazenda vira gestor dela.
create function privado.vincular_criador_como_gestor()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is not null then
    insert into public.vinculos (fazenda_id, usuario_id, papel, criado_por)
    values (new.id, (select auth.uid()), 'gestor', (select auth.uid()));
  end if;
  return new;
end;
$$;

create trigger vincular_criador_como_gestor after insert on public.fazendas
  for each row execute function privado.vincular_criador_como_gestor();

-- D-03: funcionário tem vínculo ativo com uma única fazenda (e não acumula
-- vínculo de gestor em outra). Bloqueio por usuário evita corrida entre inserts.
create function privado.validar_funcionario_unica_fazenda()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.apagado_em is not null then
    return new;
  end if;

  perform pg_advisory_xact_lock(hashtextextended(new.usuario_id::text, 0));

  if new.papel = 'funcionario' and exists (
    select 1 from public.vinculos v
    where v.usuario_id = new.usuario_id
      and v.id <> new.id
      and v.apagado_em is null
  ) then
    raise exception 'Funcionário só pode ter vínculo com uma fazenda (D-03).'
      using errcode = 'P0001';
  end if;

  if new.papel = 'gestor' and exists (
    select 1 from public.vinculos v
    where v.usuario_id = new.usuario_id
      and v.id <> new.id
      and v.papel = 'funcionario'
      and v.apagado_em is null
  ) then
    raise exception 'Usuário já é funcionário de outra fazenda (D-03).'
      using errcode = 'P0001';
  end if;

  return new;
end;
$$;

create trigger validar_funcionario_unica_fazenda
  before insert or update of papel, usuario_id, fazenda_id, apagado_em on public.vinculos
  for each row execute function privado.validar_funcionario_unica_fazenda();

-- -----------------------------------------------------------------------------
-- Row Level Security
-- Sem políticas para "anon": visitante não lê nada.
-- Sem políticas de DELETE: exclusão é lógica (apagado_em).
-- -----------------------------------------------------------------------------
alter table public.perfis    enable row level security;
alter table public.contas    enable row level security;
alter table public.fazendas  enable row level security;
alter table public.vinculos  enable row level security;
alter table public.aparelhos enable row level security;

-- perfis
create policy "perfis: ver o próprio e de quem trabalha na mesma fazenda"
  on public.perfis for select to authenticated
  using (id = (select auth.uid()) or privado.compartilha_fazenda(id));

create policy "perfis: editar o próprio"
  on public.perfis for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- contas
create policy "contas: ver se é dono ou trabalha numa fazenda da conta"
  on public.contas for select to authenticated
  using (dono_id = (select auth.uid()) or privado.tem_acesso_conta(id));

create policy "contas: criar como dono"
  on public.contas for insert to authenticated
  with check (dono_id = (select auth.uid()));

create policy "contas: dono edita"
  on public.contas for update to authenticated
  using (dono_id = (select auth.uid()))
  with check (dono_id = (select auth.uid()));

-- fazendas
-- O dono da conta também enxerga (necessário para INSERT ... RETURNING, já que
-- o vínculo de gestor só é criado no trigger AFTER INSERT).
create policy "fazendas: ver se tem vínculo ou é dono da conta"
  on public.fazendas for select to authenticated
  using (privado.tem_acesso_fazenda(id) or privado.eh_dono_conta(conta_id));

create policy "fazendas: dono da conta cria"
  on public.fazendas for insert to authenticated
  with check (privado.eh_dono_conta(conta_id));

create policy "fazendas: gestor ou dono da conta edita"
  on public.fazendas for update to authenticated
  using (privado.eh_gestor_fazenda(id) or privado.eh_dono_conta(conta_id))
  with check (privado.eh_gestor_fazenda(id) or privado.eh_dono_conta(conta_id));

-- vinculos
create policy "vinculos: ver os próprios ou os da fazenda que gerencia"
  on public.vinculos for select to authenticated
  using (usuario_id = (select auth.uid()) or privado.eh_gestor_fazenda(fazenda_id));

create policy "vinculos: gestor cria na sua fazenda"
  on public.vinculos for insert to authenticated
  with check (privado.eh_gestor_fazenda(fazenda_id));

create policy "vinculos: gestor edita na sua fazenda"
  on public.vinculos for update to authenticated
  using (privado.eh_gestor_fazenda(fazenda_id))
  with check (privado.eh_gestor_fazenda(fazenda_id));

-- aparelhos
create policy "aparelhos: ver os próprios ou os da fazenda que gerencia"
  on public.aparelhos for select to authenticated
  using (usuario_id = (select auth.uid()) or privado.eh_gestor_fazenda(fazenda_id));

create policy "aparelhos: usuário registra o próprio aparelho na sua fazenda"
  on public.aparelhos for insert to authenticated
  with check (
    usuario_id = (select auth.uid())
    and privado.tem_acesso_fazenda(fazenda_id)
    and revogado_em is null
    and revogado_por is null
  );

create policy "aparelhos: gestor edita/revoga"
  on public.aparelhos for update to authenticated
  using (privado.eh_gestor_fazenda(fazenda_id))
  with check (privado.eh_gestor_fazenda(fazenda_id));
