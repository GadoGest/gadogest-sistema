# FLUXO DE TRABALHO — GadoGest

> Como a equipe trabalha no repositório `GadoGest/gadogest-sistema` sem conflitos, sem perder trabalho e mantendo os dois Claudes (um de cada desenvolvedor) com o mesmo contexto.
> Decidido em 16/11/2026 (D-12 e D-13 em `docs/DECISOES.md`).

---

## 1. Quem cuida de quê

| Área | Responsável | Pastas |
|---|---|---|
| **Front-end**: app mobile (campo) e painel web (gestor) | **Kadu** (`Kadu-cell`) | `apps/mobile/`, `apps/web/` |
| **Back-end**: banco, migrations, RLS, Edge Functions, regras de sincronização | **Pedro** | `supabase/` |
| **Compartilhado**: tipos gerados do banco, regras de negócio comuns | os dois, com aviso no PR | `packages/shared/` |
| **Documentação** | os dois | `CLAUDE.md`, `docs/` |

Estrutura planejada do repositório (as pastas são criadas a partir da Etapa 0, quando houver código de verdade):

```
gadogest-sistema/
├── apps/
│   ├── mobile/      ← Expo / React Native (Android primeiro)
│   └── web/         ← Next.js (painel do gestor)
├── supabase/        ← migrations, RLS, Edge Functions
├── packages/
│   └── shared/      ← tipos TypeScript gerados do banco e utilitários comuns
└── docs/
```

**Regra:** cada um altera só as pastas da sua área. Precisa de algo na área do outro (ex.: um campo novo numa tabela)? **Peça ao responsável** (issue ou comentário no PR); não altere por conta própria.

---

## 2. Branches e Pull Requests

- A branch **`main` está sempre funcionando**. Ninguém faz commit direto nela quando se tratar de código.
- Cada tarefa ganha uma branch própria, criada a partir da `main` atualizada:
  - `front/<tarefa>` — ex.: `front/tela-animais`
  - `back/<tarefa>` — ex.: `back/tabela-animais`
  - `docs/<assunto>` — ex.: `docs/decisao-permissoes`
- Ao terminar: commit → push da branch → **Pull Request** para a `main` → o outro revisa → merge.
- Branches **pequenas e curtas** (1 a 3 dias). Quanto mais tempo uma branch fica separada, maior a chance de conflito.
- Exceção: mudanças **apenas de documentação** podem ir direto para a `main`, desde que o outro seja avisado.
- Recomendado: proteger a `main` no GitHub (Settings → Branches → exigir Pull Request antes do merge).

---

## 3. Contrato entre front e back: o banco de dados

O front e o back se comunicam pelo **esquema do banco**. Ordem para cada módulo:

1. **Back (Pedro)** cria ou altera a tabela numa migration em `supabase/migrations/`, com RLS por `fazenda_id`.
2. **Back** gera os tipos TypeScript do banco em `packages/shared/` e abre o PR (migration + tipos juntos).
3. Após o merge, **Front (Kadu)** faz `git pull` e usa esses tipos nas telas.
4. Se um campo mudar, o TypeScript acusa erro no front na hora — o problema aparece antes de virar bug.

Regras:
- **Nunca editar à mão** o arquivo de tipos gerado; ele é sempre regerado a partir do banco.
- Mudança que **quebra** o front (renomear/remover campo) precisa ser avisada no PR e combinada antes.
- Respeitar os princípios do `CLAUDE.md` §6 (UUID gerado no aparelho, idempotência, eventos históricos, exclusão lógica, `fazenda_id`).

---

## 4. Rotina diária (vale para os dois)

**Ao começar:**
```bash
git checkout main
git pull
```
Depois criar ou atualizar a branch da tarefa. Pedido equivalente ao Claude: *"atualize a main com git pull, me resuma o que mudou e crie uma branch para <tarefa>"*.

**Ao terminar (ou a cada parte que funcione):**
- Commit com mensagem clara (ex.: `back: cria tabela de animais com RLS`).
- Push da branch e Pull Request.
- Pedido equivalente ao Claude: *"faça commit, push e abra um Pull Request"*.

**Se a sessão do Claude já estava aberta quando houve atualização:** pedir *"leia de novo o CLAUDE.md e o docs/DECISOES.md"*.

---

## 5. Comunicação

- **Tarefas:** issues no GitHub, com responsável. Quadro em **Projects** (A fazer / Fazendo / Feito).
- **Decisões:** sempre registradas em `docs/DECISOES.md`, no mesmo PR da mudança. **O que não está escrito no repositório, o Claude do outro não sabe** — conversas com o Claude e mensagens no WhatsApp não são compartilhadas.
- **Avisos de mudança:** ativar **Watch → All Activity** no repositório para receber e-mail a cada push e PR.

---

## 6. Identidade nos commits

Cada desenvolvedor faz commit com a **própria** conta do GitHub (configurada só neste repositório):

```bash
git config user.name "<seu-usuario-github>"
git config user.email "<seu-email-noreply-do-github>"
```

- Kadu: `Kadu-cell` / `316351106+Kadu-cell@users.noreply.github.com`, sem a linha `Co-Authored-By: Claude`.
- Pedro: a própria conta dele (definir na máquina dele).

O e-mail noreply de cada um está em github.com/settings/emails.

---

## 7. Se acontecer um conflito

Nenhum trabalho se perde: o Git marca o trecho com as duas versões e pede para alguém escolher. Peça ao Claude: *"resolva o conflito, me mostre o que ficou e explique o que cada versão fazia"*. Em caso de dúvida sobre qual versão vale, converse com o outro antes de concluir.

---

## 8. Checklist de fim de sessão

Ao encerrar qualquer sessão de trabalho com o Claude (Kadu ou Pedro), o Claude deve apresentar este checklist, **marcando o que já foi feito e apontando o que falta**, e oferecer-se para executar os itens pendentes:

1. **Decisões registradas** — toda decisão tomada na conversa está em `docs/DECISOES.md`? (O que ficou só no chat, o Claude do outro não sabe.)
2. **Docs atualizados** — se algo foi implementado ou mudou de status, `docs/ROADMAP.md` (e `REQUISITOS.md`, se for o caso) foram atualizados?
3. **Commit** — todas as alterações estão commitadas, com mensagem clara e com o usuário de quem trabalhou?
4. **Push** — os commits foram enviados ao GitHub? Sem push, o outro não recebe nada.
5. **Pull Request** — se foi código numa branch, o PR foi aberto e o outro avisado para revisar?
6. **Impacto no outro** — houve mudança que afeta a área do outro (campo de tabela, tipo em `packages/shared/`, regra de negócio)? Se sim, está descrita no PR e o outro foi avisado.
7. **Próximo passo** — deixar anotado (no PR, numa issue ou em `docs/ROADMAP.md`) o que ficou pela metade e qual é o próximo passo.

Para o outro desenvolvedor, a contrapartida no começo da sessão seguinte é: `git pull` na `main` e pedir ao Claude um resumo do que mudou.
