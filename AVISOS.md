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

### A-02 · Para: Pedro · Criar a conta e a instância do PowerSync
Origem: D-25 (contas em nome da GadoGest), D-33, D-36.
1. Acesse https://dashboard.powersync.com e crie a conta **com o e-mail da GadoGest** (não um pessoal).
2. Crie uma organização/projeto **GadoGest** e, dentro dele, uma instância chamada **`gadogest-dev`**. Se houver opção de região, escolha a mais próxima do Brasil (a região não muda depois).
3. Ainda **não** preencha a conexão com o banco: ela depende do aviso A-03.
4. Crie um **token pessoal** (Access Tokens no painel) e guarde no gerenciador de senhas. Ele é pedido no `npx powersync@0.9.0 login`.

### A-03 · Para: Pedro · Definir a senha do `powersync_role` no Supabase
Origem: migration `20261117165858_prova_offline.sql` (o usuário foi criado **sem senha**; senha nunca vai para o Git).
1. Gere uma senha forte no gerenciador de senhas (sem aspas simples).
2. Painel do Supabase → projeto **gadogest-dev** → **SQL Editor** → nova consulta.
3. Rode: `alter role powersync_role with password 'SUA_SENHA';` (troque `SUA_SENHA`).
4. Guarde a senha no gerenciador de senhas como "gadogest-dev / powersync_role".
5. **Não** cole a senha no chat do Claude nem em arquivos do repositório.

### A-04 · Para: Pedro · Ligar o PowerSync ao gadogest-dev e publicar as regras
Origem: D-36, `powersync/README.md`. Depende de A-02 e A-03.
1. No terminal, na pasta do projeto: `npx powersync@0.9.0 login` (cole o token do A-02).
2. Peça ao Claude: *"ligue a pasta powersync/ à instância gadogest-dev e publique as regras"*. Ele roda `init`/`link`, preenche o `service.yaml` (conexão com `powersync_role`, login do Supabase) e faz `validate` e `deploy --dry-run`.
3. Quando pedir a senha do banco, defina a variável de ambiente **você mesmo** no terminal (o Claude não digita senhas).
4. Confira no painel do PowerSync que a instância aparece como conectada.
5. Anote a **URL da instância** (algo como `https://....powersync.journeyapps.com`) e passe para o Kadu (aviso A-06).

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
5. Variáveis no `apps/mobile/.env`: as do Supabase (já no `.env.example`) e a **URL da instância do PowerSync** (o Pedro passa no A-04). Atualize o `.env.example` com o nome da nova variável.
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
3. **PowerSync e Expo:** criar já com o e-mail da GadoGest (ver A-02).
4. Quem conferir, mova este aviso para "resolvidos" com o resultado.

## Avisos resolvidos

*(Mova para cá os avisos concluídos, com a data e quem fez.)*

---

**Como os avisos aparecem no terminal:** o hook `.githooks/post-merge` (e `post-rewrite`, para `git pull --rebase`) roda `node scripts/avisos.mjs` depois do pull. O `npm install` liga os hooks sozinho (script `prepare`). Se não aparecer, rode uma vez: `git config core.hooksPath .githooks`.
