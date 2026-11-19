# AVISOS — o que cada um precisa fazer

> Este arquivo aparece no terminal **depois de todo `git pull`** (hook em `.githooks/`; ver o fim deste arquivo).
> Também dá para ver a qualquer hora com `npm run avisos`.
>
> **Regras:**
> - Cada aviso tem um **ID**, **para quem** é e o **passo a passo**. Escreva de forma que a pessoa consiga fazer sem perguntar.
> - Criou uma tarefa para o outro (ou para você mesmo, fora do código)? Acrescente um aviso **no mesmo PR**.
> - Terminou? **Mova o aviso para "Avisos resolvidos"** com a data, no PR em que o passo foi feito (ou num PR `docs/...`).
> - O formato do título precisa ser exatamente `### A-NN · Para: <Pedro | Kadu | Todos> · <título>`, senão o aviso não aparece no terminal.

## Avisos abertos

### A-10 · Para: Pedro · Passar o login de teste para o Kadu
Origem: A-05 (resolvido).
1. Mande ao Kadu, **por canal privado** (não no GitHub), o e-mail `teste@gadogest.com.br` e a senha que você definiu no Supabase.
2. Quando ele confirmar que recebeu, mova este aviso para "resolvidos".

### A-07 · Para: Kadu · Revisar as permissões provisórias (D-26) e fechar a Q-20
Origem: D-17, D-26.
1. Leia a D-26 em `docs/DECISOES.md`: dono da conta cria fazendas; gestor gerencia tudo; funcionário lê e registra o próprio aparelho.
2. Decida o que falta da Q-20: **troca de lote, nascimento, manejos agendados e acesso ao painel web** do funcionário.
3. Registre como decisão nova em `docs/DECISOES.md` (PR `docs/...`) e avise o Pedro para ajustar o RLS.

### A-08 · Para: Kadu · Ativar a proteção da `main` no GitHub
Origem: D-31 (aplicação pendente).
1. GitHub → repositório `gadogest-sistema` → **Settings** → **Branches** (ou **Rules → Rulesets**).
2. Regra para `main`: **Require a pull request before merging** com **1 approval**.
3. Se o plano gratuito da organização não permitir em repositório privado, registre isso na D-31.

### A-09 · Para: Todos · Conferir se os serviços estão em nome da GadoGest
Origem: D-25.
1. **Supabase:** o projeto `gadogest-dev` está numa organização da GadoGest? (Painel → nome da organização no topo.) Se estiver numa conta pessoal, transfira em Organization Settings.
2. **GitHub:** o repositório já está na organização GadoGest. ✓
3. **PowerSync:** conta criada com o e-mail da GadoGest (organização "GadoGest's Projects"). ✓ **Expo:** criar já com o e-mail da GadoGest.
4. Quem conferir, mova este aviso para "resolvidos" com o resultado.

## Avisos resolvidos

*(Mova para cá os avisos concluídos, com a data e quem fez.)*

- **A-01 · Revisar e aprovar o PR #5** — 17/11/2026, Kadu. PRs #5 e #6 aprovados e unidos à `main`.
- **A-02 · Conta e instância do PowerSync** — 17/11/2026, Pedro. Conta com o e-mail da GadoGest; projeto **GadoGest** com as instâncias `Development` (usada, região `br`/São Paulo) e `Production` (sem uso). Cadastro em https://accounts.powersync.com/portal/powersync-signup (o `dashboard.powersync.com` só tem login).
- **A-03 · Senha do `powersync_role`** — 17/11/2026, Pedro (com o Claude). Senha aleatória gerada sem ser exibida, aplicada no banco só como hash SCRAM e guardada em `powersync/.env` na máquina do Pedro (ignorado pelo Git). Outra máquina que for fazer deploy precisa desse valor por canal privado, ou de uma senha nova.
- **A-04 · PowerSync ligado ao gadogest-dev** — 17/11/2026, Pedro (com o Claude). `deploy` feito; conexão `connected`, replicação inicial concluída de `teste_animais` e `vinculos`. URL: `https://6afcc9d43224a694a45abf6e.powersync.journeyapps.com`.
- **A-05 · Usuário e fazenda de teste** — 18/11/2026, Pedro (com o Claude). Usuário `teste@gadogest.com.br` (Auth, confirmado) é **gestor** da "Fazenda de teste" (`00000000-0000-4000-8000-000000000001`), na "Conta de teste", da qual é dono. Vínculo já replicado pelo PowerSync.
- **A-06 · Login e envio no app (uploadData)** — 19/11/2026, Kadu (com o Claude), branch `front/login-upload`. Login com sessão guardada no aparelho (D-38), envio pela `sincronizar_teste_animal` e edição com `versao + 1`. Nova variável `EXPO_PUBLIC_POWERSYNC_URL` no `.env.example`: **quem já tem `apps/mobile/.env` precisa acrescentá-la**. Teste em modo avião aprovado no Moto G60: 3 registros no servidor sem duplicar, edição aplicada, nenhuma pendência.

---

**Como os avisos aparecem no terminal:** o hook `.githooks/post-merge` (e `post-rewrite`, para `git pull --rebase`) roda `node scripts/avisos.mjs` depois do pull. O `npm install` liga os hooks sozinho (script `prepare`). Se não aparecer, rode uma vez: `git config core.hooksPath .githooks`.
