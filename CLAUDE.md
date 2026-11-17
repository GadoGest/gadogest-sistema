# CLAUDE.md — GadoGest

> Arquivo de contexto principal para o Claude Code. Gerado em 16/11/2026 a partir do Project "GadoGest" (descrição, instruções e documento central v1.0, de novembro/2026) e das informações já fornecidas pelo usuário sobre o projeto.
>
> **Leia isto antes de qualquer alteração.** Detalhes ficam em `docs/REQUISITOS.md`, `docs/CONTEXTO.md`, `docs/ROADMAP.md` e `docs/DECISOES.md`.

---

## 0. Aviso de fidelidade e legenda

Esta documentação **não foi gerada a partir do código**. O estado real do repositório **não foi verificado**. Regra do projeto: *não presumir que a documentação representa o estado atual do código*. Antes de implementar qualquer coisa, inspecione o repositório.

Legenda usada nos arquivos:

| Marca | Significado |
|---|---|
| **[DECLARADO]** | Instrução ou definição explícita do usuário/Project |
| **[PLANEJADO]** | Consta no plano técnico (documento central v1.0), mas não está confirmado como aprovado nem como implementado |
| **[PENDENTE]** | Ainda precisa ser decidido. **Não invente a resposta.** |
| **[CONFLITO]** | Duas fontes se contradizem. **Não escolha sozinho; pergunte.** |
| **[A VERIFICAR]** | Depende de olhar o código/repositório |

---

## 1. Plataforma e stack

> **✅ RESOLVIDO em 16/11/2026 (D-01 em `docs/DECISOES.md`):** o GadoGest será **app mobile (campo, Android primeiro) + painel web (gestor)**, conforme o plano técnico v1.0. A opção desktop (Electron/Prisma) foi descartada. Nesta data não havia código do sistema; o desenvolvimento parte do zero. A tabela abaixo fica como histórico do conflito.

As duas fontes do Project descrevem produtos tecnicamente diferentes. **Isso precisa ser resolvido com o usuário antes de qualquer trabalho de arquitetura.**

| | Descrição/instruções do Project **[DECLARADO]** | Documento central v1.0 (plano técnico) **[PLANEJADO]** |
|---|---|---|
| Tipo de app | **Software desktop** | **App mobile (campo) + painel web (gestor)** |
| Runtime/UI | Electron + React | React Native + Expo (mobile) e Next.js (web) |
| Linguagem | TypeScript | TypeScript |
| Estilo | Tailwind CSS | não especificado |
| Dados | Prisma ORM + SQLite (local) | SQLite local no aparelho + PostgreSQL central (Supabase) |
| Sincronização | não mencionada | PowerSync |
| Backend/Auth | não mencionados ("funcionamento local") | Supabase (Auth, RLS, Edge Functions) |
| Licença/aparelhos | não mencionados | licença offline assinada, controle de aparelhos |

Ponto em comum: ambos são **offline-first/local-first**, em TypeScript, com SQLite.

O documento central diz expressamente: *"essa é a arquitetura planejada no documento técnico. Antes de realizar qualquer alteração, o Claude deverá verificar o estado real do repositório e das tecnologias efetivamente adotadas."* Portanto:

1. Verifique o repositório (`package.json`, estrutura de pastas, schema Prisma, dependências Electron/Expo etc.).
2. Descubra qual das duas arquiteturas existe de fato (ou se há ambas).
3. Reporte ao usuário e peça confirmação. Não migre, reescreva nem "alinhe" uma arquitetura à outra por conta própria.

**Repositório do sistema (resolvido em 16/11/2026, D-10):** o código do app e do painel fica em `GadoGest/gadogest-sistema` (GitHub, organização GadoGest), separado do site. Clone local: `C:\Users\carlo\gadogest-sistema` (fora do Google Drive). O site/página de apresentação (React + Vite, `gadogest.com.br`) fica em **`GadoGest/gadogest-site`** (D-11).

---

## 2. Identidade e objetivo

O **GadoGest** é uma plataforma de gestão de **gado de corte** para **pequenos produtores rurais** (podendo atender propriedades de pequeno e médio porte). Substitui cadernos, fichas e planilhas por uma solução digital centralizada, acessível, intuitiva e **offline-first**.

Objetivo: dar ao pequeno produtor organização, controle e acesso à informação para decidir melhor, com foco forte em **saúde animal** (histórico sanitário, vacinas, medicamentos, tratamentos, exames) e em indicadores úteis à decisão.

Visão de futuro (não é escopo atual): plataforma completa de gestão pecuária, com análises de desempenho, recomendações de manejo, gestão financeira e integração com equipamentos rurais.

Contexto do negócio: startup acadêmica/empreendedora em estágio de protótipo; produto comercial por assinatura (ver §10 e `docs/CONTEXTO.md`).

**Princípio fundamental:** construir uma ferramenta **confiável, acessível e realmente útil**. Não basta ter muitas funcionalidades ou tecnologia moderna: o sistema precisa funcionar com conectividade limitada, proteger os dados e ser simples o bastante para o produtor usar sem dificuldade.

---

## 3. Problema que resolve

Dependência de cadernos/planilhas; dificuldade de consultar histórico individual; registros sanitários desorganizados; dificuldade de acompanhar vacinas, medicamentos e tratamentos; ausência de alertas de manejo; dificuldade de acompanhar peso/desenvolvimento e movimentações; informação descentralizada; conectividade limitada no campo; falta de ferramentas tecnológicas simples e acessíveis.

Validação inicial: discussão com produtores e pessoas próximas à realidade rural; em questionário, **6 de 8** entrevistados reconheceram o problema (validação inicial, **não** pesquisa estatística representativa). O usuário também informou validação envolvendo **12 fazendas** (ver conflito/ressalva em `docs/CONTEXTO.md`).

---

## 4. Público-alvo

- **Produtor/gestor**: decide compra, venda, manejo; usa principalmente o painel/visão gerencial.
- **Funcionário/operador de campo**: registra no curral; precisa de poucos passos e interface simples.
- **Influenciadores técnicos**: veterinários e técnicos agropecuários.
- Inclui produtores mais velhos e com pouca familiaridade com tecnologia → interface **muito** simples.
- **Persona de referência: Aglauto** — pequeno produtor com rotina intensa, não quer planilhas complexas, pode não ter balança de precisão e estimar peso por fita de pesagem. Considerar isso em decisões de interface e funcionalidades.

---

## 5. Funcionalidades (resumo)

Detalhes, IDs e status por módulo em `docs/REQUISITOS.md`.

**Prioritárias do MVP [PLANEJADO]:** login; fazendas; lotes; cadastro de animais e ficha individual; movimentações; saúde e sanidade; manejos agendados; alertas; pesagens e GMD; sincronização offline; painel com dashboard, consulta de animais/sanidade, usuários, aparelhos, configurações; financeiro básico *se confirmado no escopo final*.

**Fora do MVP [PLANEJADO]:** reprodução completa; troca de dados por QR Code e Bluetooth; financeiro detalhado; relatórios avançados/exportáveis; cobrança automática; app iOS; integração com balanças e RFID.

**Módulos citados na descrição do Project [DECLARADO]:** fazendas, pessoas, animais, pesagens, lotes, movimentações, sanidade, reprodução, alimentação, estoque, financeiro, relatórios e dashboard. Não está confirmado quais já existem no código.

---

## 6. Regras de negócio e requisitos inegociáveis

Valem para qualquer funcionalidade (fonte: plano técnico — **[PLANEJADO]**, tratadas como princípios a respeitar):

1. **Offline-first**: o app nunca deve exigir internet para registrar atividade de campo. Todo registro é persistido localmente **antes** de depender de sincronização.
2. **UUID gerado no dispositivo** para todos os registros sincronizados.
3. **Idempotência**: reenviar o mesmo UUID não pode duplicar registro.
4. **Eventos históricos**: vacinação, medicamentos, tratamentos, pesagens, ocorrências, nascimentos, compras, vendas, mortes e trocas de lote são **eventos**; nunca sobrescrever o histórico.
5. **Separação por fazenda**: toda informação operacional carrega `fazenda_id`; RLS e regras de sincronização impedem acesso a fazendas não autorizadas.
6. **Exclusão lógica** (`apagado_em`); restauração é ação explícita.
7. **Derivados calculados, não armazenados**: status sanitário e GMD são calculados a partir dos registros.
8. **Brinco único por fazenda**; duplicidade criada offline é detectada após sincronização e resolvida explicitamente pelo gestor. **Nenhum registro pode ser perdido silenciosamente.**
9. **Segurança no backend** (RLS). Esconder algo na interface **não** é proteção.
10. **O GadoGest organiza registros; não substitui diagnóstico, prescrição ou orientação de médico-veterinário.**
11. Estimativa de peso por fita deve ser sempre identificada como **estimativa**, nunca como medição em balança.

---

## 7. Tecnologias e arquitetura

Ver o conflito no §1. Resumo do que cada fonte define:

**Plano técnico v1.0 [PLANEJADO]** — TypeScript em todas as camadas (recomendação; confirmação da equipe pendente):

| Camada | Tecnologia |
|---|---|
| App mobile | React Native + Expo (Android primeiro) |
| BD local | SQLite |
| Sincronização | PowerSync |
| Backend | Supabase |
| BD central | PostgreSQL |
| Auth | Supabase Auth |
| Segurança | Row Level Security |
| Funções de servidor | Supabase Edge Functions |
| Painel web | Next.js + TypeScript |

Python: possível uso futuro em análises/relatórios complexos. **PHP não faz parte da arquitetura.**

**Descrição do Project [DECLARADO]:** software desktop com Electron, React, TypeScript, Tailwind CSS, Prisma ORM e SQLite, priorizando funcionamento local, segurança, organização e facilidade de manutenção.

**Site/pitch** (projeto separado do sistema): React + Vite, publicado via GitHub + Vercel, `gadogest.com.br`.

---

## 8. Padrões de desenvolvimento

**Convenções de dados [PLANEJADO]:**
- IDs em UUID; `fazenda_id` para isolamento; `criado_em`, `atualizado_em`, `apagado_em`; campos de autoria/aparelho quando aplicável.
- Datas em ISO/UTC no armazenamento; **exibição em formato brasileiro**.
- **Valores monetários em centavos.**
- Peso em kg, **uma casa decimal na apresentação**.

**Código:**
- Código limpo, legível e sustentável; tipagem consistente.
- Respeitar a arquitetura existente; não duplicar estruturas; não reescrever módulos sem necessidade.
- Não adicionar dependências desnecessárias.
- Considerar offline e sincronização desde o início; respeitar permissões por fazenda; preservar histórico de eventos.

**Interface:**
- Profissional, moderna, limpa, intuitiva; **predominância de tons de verde**.
- Botões grandes; poucos passos por operação; textos objetivos; navegação simples; boa legibilidade; hierarquia visual clara; feedback imediato; **indicador de sincronização**; adequada ao uso no campo; consistência entre app e painel.
- Não deve parecer um sistema administrativo genérico e complexo.
- **Não descaracterizar a interface existente.**

**Idioma:** português brasileiro por padrão (comunicação, textos de UI, documentação).

---

## 9. Como trabalhar neste projeto

### Antes de implementar
1. Analise a estrutura atual do projeto e leia os arquivos relevantes.
2. Identifique tecnologias e padrões existentes.
3. Verifique se a funcionalidade **já existe**.
4. Avalie impactos nos demais módulos, no **offline** e na **sincronização**.
5. Não presuma que a documentação reflete o código.

### Ao analisar problemas
Identifique a causa provável → explique → recomende a solução → liste arquivos/módulos afetados → avalie riscos → **aguarde autorização quando a equipe pedir análise antes de implementar.** Não faça alterações destrutivas ou migrações arriscadas sem explicar as consequências.

### Qualidade e testes
Sempre que possível, testar: operações offline; sincronização; idempotência; permissões; isolamento entre fazendas; cadastro e movimentação de animais; eventos sanitários; aplicação em lote; cálculo de GMD; exclusão lógica; licenciamento offline; desempenho em dispositivos modestos (Android simples).

**Não declare uma implementação concluída só porque o código foi escrito.** Informe o que foi testado, os resultados e o que ainda precisa de validação. **Não invente resultados de testes nem estruturas de arquivos.**

### Comunicação
Português BR, claro, objetivo, profissional; explique decisões de forma compreensível; apresente recomendações com justificativa; priorize o MVP e evite complexidade prematura; não assuma decisões não aprovadas.

---

## 10. Restrições — não alterar sem autorização expressa do usuário

- A **arquitetura/stack** (e a resolução do conflito do §1).
- A **interface existente** e a identidade visual (verde).
- **Funcionalidades existentes** (só com justificativa).
- Os **princípios do §6** (offline-first, UUID, idempotência, eventos, `fazenda_id`/RLS, exclusão lógica, derivados calculados, brinco único).
- **Escopo do MVP**: não implementar recursos pós-MVP sem alinhamento; não tratar funcionalidade planejada como implementada.
- **Dependências**: não adicionar sem necessidade.
- **Modelo de negócio**: R$ 89,90/mês é só **valor de referência**; não tratar cobrança por conta/fazenda, limite de aparelhos, planos ou gateway como definidos (ver `docs/DECISOES.md`).
- **Respostas às pendências**: não inventar (ver §12).
- **Dados fictícios dos mockups** (ex.: "Fazenda Santa Helena", "João Silva", 245 animais) são ilustrativos; não usar como dados reais nem como requisito.
- **Slogans/identidade de comunicação**: "Inovar para Cuidar" é o **tema do evento Agro Startup, não slogan do GadoGest**. Não adicionar atribuição "by Claude" na página do pitch/site (já foi retirada).

---

## 11. Git, commits e trabalho em equipe

> **⚠️ REGRA DE FIM DE SESSÃO (obrigatória):** sempre que o usuário indicar que vai encerrar, pausar ou terminou o trabalho (ex.: "por hoje é isso", "pode parar", "terminamos", "ainda não, depois continuo"), ou quando uma tarefa for concluída, **apresente o checklist de fim de sessão** de `docs/FLUXO-DE-TRABALHO.md` §8 — decisões em `DECISOES.md`, docs atualizados, commit, push, PR, impacto no outro desenvolvedor, próximo passo anotado. Marque o que já está feito, aponte o que falta e ofereça executar os itens pendentes. Não encerre sem isso: é o que mantém Kadu e Pedro (e seus Claudes) sincronizados.

**Leia `docs/FLUXO-DE-TRABALHO.md` antes de criar branches, commits ou PRs.** Resumo obrigatório:

- **Áreas:** Kadu = front (`apps/mobile/`, `apps/web/`); Pedro = back (`supabase/`, `powersync/`); `packages/shared/` e `docs/` são compartilhados. **Não altere a área do outro desenvolvedor**: se a tarefa exigir, avise e sugira pedir ao responsável.
- **Branches:** nunca commitar código direto na `main`. Uma branch por tarefa (`front/...`, `back/...`, `docs/...`), PR para a `main`, revisão do outro. Documentação também passa por PR (D-31).
- **Contrato front/back:** o esquema do banco (migrations em `supabase/migrations/`) e os tipos TypeScript gerados em `packages/shared/`. Nunca editar os tipos gerados à mão.
- **Ao começar uma sessão:** sugerir `git pull` na `main` e resumir o que mudou. **Toda decisão nova** vai para `docs/DECISOES.md` no mesmo PR.
- **Avisos (`AVISOS.md`):** depois de todo `git pull`, ler `AVISOS.md` e mostrar ao usuário os avisos abertos **para ele** (pelo `git config user.name`: `Kadu-cell` = Kadu, `pedro-m-vilela` = Pedro), com o passo a passo, e oferecer ajuda nos passos que o Claude pode fazer. Quando o trabalho gerar uma tarefa para alguém fora do código (configurar serviço, revisar, decidir), **acrescentar um aviso no mesmo PR**; quando um aviso for concluído, movê-lo para "Avisos resolvidos" com a data. Manter o formato do título (`### A-NN · Para: ... · ...`), que o script `scripts/avisos.mjs` usa.
- **Identidade:** cada desenvolvedor commita com a **própria** conta GitHub (configurada com `git config` local). Antes de commitar, confira `git config user.name`; **nunca** commite em nome de outra pessoa. Se não estiver configurado, pergunte.
- **Kadu (`Kadu-cell`):** e-mail noreply `316351106+Kadu-cell@users.noreply.github.com`, **sem a linha `Co-Authored-By: Claude`** e sem trailers de coautoria.
- Repositório do sistema: `GadoGest/gadogest-sistema` (branch `main`).
- Repositório do site: `GadoGest/gadogest-site`, deploy na Vercel. A reformulação do site foi combinada em branch próprio `reformulacao` (criado a partir da `main`), conferindo pela **prévia da Vercel** antes de unir à `main`.

---

## 12. Pendências e conflitos abertos (resumo)

Lista completa e numerada em `docs/DECISOES.md` (seções "Conflitos" e "Pendências").

**Resolvidos em 16/11/2026** (ver D-01 a D-13): plataforma (mobile + web), local do código, login, funcionário em uma fazenda, aplicação em lote, financeiro e exames fora do MVP, brinco duplicado/opcional, catálogo sanitário, repositório do site, fluxo de trabalho e divisão front/back. Em 16/11/2026 **não havia código do sistema**.

**Resolvidos também em 16/11/2026, após leitura do plano técnico do MVP** (ver D-14 a D-25): stack confirmada em TypeScript; catálogo sanitário pela D-08; aparelho revogado envia pendentes antes de apagar; permissões parciais do funcionário; porte de até 5.000 cabeças; sem clientes ainda; sem data fixa no cronograma; equipe sem experiência prévia em RN/Postgres/Supabase; edição em dois aparelhos tratada como conflito para o gestor (não vale "última alteração"); licença vencida = só consulta; foto do animal fora do MVP; contas dos serviços em nome da GadoGest.

Ainda abertos:
- **[CONFLITO]** Módulos descritos como "integrados" no Project × plano técnico que os trata como planejados/pós-MVP (reprodução, alimentação, estoque, relatórios).
- **[PENDENTE]** Restante da matriz de permissões (Q-20: troca de lote, nascimento, manejos, painel); criptografia do SQLite (Q-16) e custo do PowerSync (Q-17), a validar na Etapa 0; orçamento de infraestrutura (Q-03: começar nos planos gratuitos, decidir antes do piloto); assinatura/limite de aparelhos/cobrança (Q-05, Q-06, Q-09); iPhone no piloto (Q-12); Figma (Q-13).
- **Risco técnico (D-22):** o PowerSync usa "última alteração vale" por padrão; o tratamento de conflito de edição como pendência para o gestor precisa ser provado na Etapa 0.

---

## 13. Mapa dos documentos

| Arquivo | Conteúdo |
|---|---|
| `CLAUDE.md` | Este arquivo: visão, regras, restrições, como trabalhar |
| `docs/REQUISITOS.md` | Requisitos funcionais e não funcionais, módulos, escopo MVP/pós-MVP |
| `docs/CONTEXTO.md` | Origem, histórico, equipe, validação, pitch, diferenciais, modelo de negócio |
| `docs/ROADMAP.md` | O que existe, em andamento, a desenvolver, próximas etapas |
| `docs/DECISOES.md` | Registro de decisões, conflitos e pendências |
| `docs/FLUXO-DE-TRABALHO.md` | Divisão front/back, branches, PRs, contrato pelo banco, rotina e comunicação da equipe |

Mantenha estes arquivos atualizados quando decisões forem tomadas e funcionalidades implementadas, **sempre diferenciando planejado, decidido e existente**.
