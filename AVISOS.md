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

### A-01 · Para: Kadu · Revisar e aprovar o PR #5 (prova offline do back)
Origem: PR #5, D-36. Sem ele na `main`, o app não tem a função de envio nem os tipos novos.
1. Abra https://github.com/GadoGest/gadogest-sistema/pull/5 e leia a descrição (seção "Para o Kadu").
2. Vá na aba **Files changed** → botão verde **Review changes** → marque **Approve** → **Submit review**. (Comentário escrito "aprovado" não conta como aprovação para o GitHub.)
3. Avise o Pedro para fazer o merge, ou faça você em **Merge pull request**.
4. Depois do merge: `git checkout main` e `git pull`.

### A-05 · Para: Pedro · Criar o usuário de teste e a fazenda de teste
Origem: o app usa a fazenda fixa `00000000-0000-4000-8000-000000000001`, que ainda não existe no `gadogest-dev`.
1. Painel do Supabase → **gadogest-dev** → **Authentication** → **Users** → **Add user** → **Create new user**.
2. Use um e-mail de teste da GadoGest e uma senha do gerenciador de senhas; marque **Auto Confirm User**.
3. Passe **só o e-mail** para o Claude e peça: *"crie a conta e a fazenda de teste com o id do app e vincule este usuário como gestor"*.
4. Passe o e-mail e a senha de teste para o Kadu **por um canal privado** (não no GitHub).

### A-06 · Para: Kadu · Login e envio no app (uploadData)
Origem: D-36 e descrição do PR #5. Depende de A-01; para testar de verdade, de A-04 e A-05.
1. Login com e-mail e senha pelo Supabase Auth (D-02); o token vai para o conector do PowerSync (`fetchCredentials`).
2. No `uploadData`, para cada item da fila: `supabase.rpc('sincronizar_teste_animal', { p_operacao: op.op, p_id: op.id, p_dados: op.opData ?? {} })`.
3. Qualquer `data.resultado` (`aplicado`, `ja_aplicado`, `conflito`, `rejeitado`) = processado → `transaction.complete()`. Se vier `error` (rede/login), **não** complete: deixe na fila.
4. **Toda edição sobe `versao` em 1** no mesmo `UPDATE` local (`versao = versao + 1`). Sem isso o servidor recusa (`versao_ausente`) ou marca conflito.
5. Variáveis no `apps/mobile/.env`: as do Supabase (já no `.env.example`) e a **URL da instância do PowerSync**: `https://6afcc9d43224a694a45abf6e.powersync.journeyapps.com` (não é segredo). Atualize o `.env.example` com o nome da nova variável.
6. Teste em modo avião: cadastre offline, volte a conexão e confira no Supabase (Table Editor → `teste_animais`).

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

- **A-02 · Conta e instância do PowerSync** — 17/11/2026, Pedro. Conta com o e-mail da GadoGest; projeto **GadoGest** com as instâncias `Development` (usada, região `br`/São Paulo) e `Production` (sem uso). Cadastro em https://accounts.powersync.com/portal/powersync-signup (o `dashboard.powersync.com` só tem login).
- **A-03 · Senha do `powersync_role`** — 17/11/2026, Pedro (com o Claude). Senha aleatória gerada sem ser exibida, aplicada no banco só como hash SCRAM e guardada em `powersync/.env` na máquina do Pedro (ignorado pelo Git). Outra máquina que for fazer deploy precisa desse valor por canal privado, ou de uma senha nova.
- **A-04 · PowerSync ligado ao gadogest-dev** — 17/11/2026, Pedro (com o Claude). `deploy` feito; conexão `connected`, replicação inicial concluída de `teste_animais` e `vinculos`. URL: `https://6afcc9d43224a694a45abf6e.powersync.journeyapps.com`.

---

**Como os avisos aparecem no terminal:** o hook `.githooks/post-merge` (e `post-rewrite`, para `git pull --rebase`) roda `node scripts/avisos.mjs` depois do pull. O `npm install` liga os hooks sozinho (script `prepare`). Se não aparecer, rode uma vez: `git config core.hooksPath .githooks`.
