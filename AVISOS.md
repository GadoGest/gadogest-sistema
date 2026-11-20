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

### A-06 · Para: Kadu · Login e envio no app (uploadData)
Origem: D-36 e descrição do PR #5. Depende de A-01; para testar de verdade, de A-04 e A-05.
1. Login com e-mail e senha pelo Supabase Auth (D-02); o token vai para o conector do PowerSync (`fetchCredentials`).
2. No `uploadData`, para cada item da fila: `supabase.rpc('sincronizar_teste_animal', { p_operacao: op.op, p_id: op.id, p_dados: op.opData ?? {} })`.
3. Qualquer `data.resultado` (`aplicado`, `ja_aplicado`, `conflito`, `rejeitado`) = processado → `transaction.complete()`. Se vier `error` (rede/login), **não** complete: deixe na fila.
4. **Toda edição sobe `versao` em 1** no mesmo `UPDATE` local (`versao = versao + 1`). Sem isso o servidor recusa (`versao_ausente`) ou marca conflito.
5. Variáveis no `apps/mobile/.env`: as do Supabase (já no `.env.example`) e a **URL da instância do PowerSync**: `https://6afcc9d43224a694a45abf6e.powersync.journeyapps.com` (não é segredo). Atualize o `.env.example` com o nome da nova variável.
6. Teste em modo avião: cadastre offline, volte a conexão e confira no Supabase (Table Editor → `teste_animais`).

### A-11 · Para: Pedro · Aplicar as permissões da D-37 no RLS das próximas etapas
Origem: A-07 (resolvido), D-17, D-26 e D-37.
1. Leia a **D-37** em `docs/DECISOES.md`. A D-26 foi aprovada pelo Kadu **sem mudanças**, então o RLS da fundação continua como está.
2. Quando criar as tabelas das Etapas 2 e 3, o funcionário **pode** registrar troca de lote e nascimento, e **pode marcar um manejo agendado como realizado**. **Criar, alterar ou cancelar agendamento é só do gestor.**
3. O funcionário **não acessa o painel web**. Isso precisa valer no backend também, não só escondendo telas.
4. Cubra essas regras com testes pgTAP e mova este aviso para "resolvidos" quando as tabelas existirem.

### A-12 · Para: Todos · Passar o repositório `gadogest-sistema` para privado
Origem: A-08 (resolvido), D-31 e **D-39** (decidido em 19/11/2026: o repositório fica **privado**; a mudança foi deixada para depois).
1. Antes de mudar, decidam como fica a proteção da `main`: no plano gratuito ela provavelmente **deixa de funcionar** em repositório privado. Opções: seguir só pelo combinado (PR e aprovação do outro, sem trava do GitHub) ou assinar o GitHub Team (cerca de US$ 4 por usuário/mês).
2. GitHub → repositório `gadogest-sistema` → **Settings** → **General** → fim da página, **Danger Zone** → **Change repository visibility** → **Make private** → confirmar.
3. Registre na D-39 a data da mudança e a opção escolhida para a proteção da `main`, e mova este aviso para "resolvidos".

## Avisos resolvidos

*(Mova para cá os avisos concluídos, com a data e quem fez.)*

- **A-01 · Revisar e aprovar o PR #5** — 17/11/2026, Kadu. PRs #5 e #6 aprovados e unidos à `main`.
- **A-02 · Conta e instância do PowerSync** — 17/11/2026, Pedro. Conta com o e-mail da GadoGest; projeto **GadoGest** com as instâncias `Development` (usada, região `br`/São Paulo) e `Production` (sem uso). Cadastro em https://accounts.powersync.com/portal/powersync-signup (o `dashboard.powersync.com` só tem login).
- **A-03 · Senha do `powersync_role`** — 17/11/2026, Pedro (com o Claude). Senha aleatória gerada sem ser exibida, aplicada no banco só como hash SCRAM e guardada em `powersync/.env` na máquina do Pedro (ignorado pelo Git). Outra máquina que for fazer deploy precisa desse valor por canal privado, ou de uma senha nova.
- **A-04 · PowerSync ligado ao gadogest-dev** — 17/11/2026, Pedro (com o Claude). `deploy` feito; conexão `connected`, replicação inicial concluída de `teste_animais` e `vinculos`. URL: `https://6afcc9d43224a694a45abf6e.powersync.journeyapps.com`.
- **A-05 · Usuário e fazenda de teste** — 18/11/2026, Pedro (com o Claude). Usuário `teste@gadogest.com.br` (Auth, confirmado) é **gestor** da "Fazenda de teste" (`00000000-0000-4000-8000-000000000001`), na "Conta de teste", da qual é dono. Vínculo já replicado pelo PowerSync.
- **A-10 · Passar o login de teste para o Kadu** — 19/11/2026, Pedro. Kadu recebeu a senha por canal privado e entrou no app com `teste@gadogest.com.br`.
- **A-07 · Revisar as permissões provisórias (D-26) e fechar a Q-20** — 19/11/2026, Kadu (com o Claude). D-26 aprovada sem mudanças; o restante da Q-20 virou a **D-37**. Ajuste do RLS nas próximas etapas: aviso A-11.
- **A-08 · Proteção da `main` no GitHub** — 19/11/2026, Kadu (com o Claude, pelo `gh`). PR obrigatório com 1 aprovação, sem force push e sem apagar a branch. Funcionou no plano gratuito porque o repositório é público (ver A-12).
- **A-09 · Serviços em nome da GadoGest** — 19/11/2026, Kadu (com o Claude). Supabase: organização "GadoGest" (plano Free), com o e-mail da GadoGest como único membro (Owner) e o projeto `gadogest-dev`. GitHub e PowerSync já estavam ok. **Expo**: quando for criado, usar o e-mail da GadoGest.

---

**Como os avisos aparecem no terminal:** o hook `.githooks/post-merge` (e `post-rewrite`, para `git pull --rebase`) roda `node scripts/avisos.mjs` depois do pull. O `npm install` liga os hooks sozinho (script `prepare`). Se não aparecer, rode uma vez: `git config core.hooksPath .githooks`.
