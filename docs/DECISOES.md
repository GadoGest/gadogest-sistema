# DECISÕES — GadoGest

> Registro das decisões técnicas e estratégicas, conflitos e pendências. Fontes: descrição/instruções do Project, documento central v1.0 (nov/2026) e informações fornecidas pelo usuário.
>
> **Status usados:**
> - **DECLARADO** — instrução/definição explícita do usuário ou do Project (vale como decisão, salvo conflito indicado).
> - **PLANEJADO** — consta no plano técnico; **não está confirmado como aprovado nem como implementado**. O documento central não traz uma lista de itens "aprovados"; por isso nada foi promovido a aprovado.
> - **REFERÊNCIA** — valor usado só como referência de planejamento.
>
> Ao tomar uma decisão nova ou resolver um conflito/pendência, acrescente aqui com data e fonte.

---

## 1. Decisões estratégicas e de produto

| ID | Decisão | Status | Fonte |
|---|---|---|---|
| E-01 | Produto para gestão de **gado de corte**, prioritariamente **pequenos produtores** (também pequeno/médio porte) | DECLARADO | Project / doc |
| E-02 | **Offline-first** é o diferencial central; app nunca exige internet para registrar no campo | DECLARADO | Project / doc |
| E-03 | **Saúde e sanidade** é o foco principal e um dos módulos mais importantes | DECLARADO | Project / doc / usuário |
| E-04 | Prioridade é **confiabilidade** sobre quantidade de funcionalidades; MVP enxuto e entregas graduais | PLANEJADO | Doc §11–13, §18 |
| E-05 | Se houver atraso, o **financeiro do painel é o primeiro a ser adiado** | PLANEJADO | Doc §12 |
| E-06 | **Android primeiro**; iOS fora do MVP | PLANEJADO | Doc §5.3, §11.2 |
| E-07 | O sistema **não substitui** diagnóstico, prescrição ou orientação veterinária | DECLARADO | Doc §7.4 |
| E-08 | Modelo comercial por **assinatura**; mensalidade de **R$ 89,90** como valor de **referência** | REFERÊNCIA | Doc §15 |
| E-09 | Fora do MVP: reprodução completa, QR Code/Bluetooth, financeiro detalhado, relatórios avançados, cobrança automática, iOS, balanças, RFID | PLANEJADO | Doc §11.2 |
| E-10 | Interface profissional, simples, em **tons de verde**, não genérica/administrativa; consistente entre app e painel | DECLARADO | Doc §14 / Project |
| E-11 | **Português brasileiro** por padrão em comunicação e interface | DECLARADO | Doc §17.5 |
| E-12 | Estimativa de peso por fita (futura) deve ser claramente identificada como estimativa | PLANEJADO | Doc §7.3 |
| E-13 | Persona de referência para decisões de UX: **Aglauto** | DECLARADO | Doc §3.3 |
| E-14 | GadoGest não tem endereço comercial real definido (relevante em editais) | DECLARADO | Usuário |

## 2. Decisões de comunicação, site e processo

| ID | Decisão | Status | Fonte |
|---|---|---|---|
| C-01 | Slogans próprios do GadoGest definidos (ver `CONTEXTO.md`); **"Inovar para Cuidar" é tema do evento, não slogan** | DECLARADO | Usuário |
| C-02 | Página de pitch por **QR Code, sem login**, React + Vite, publicada via GitHub + Vercel | DECLARADO | Usuário |
| C-03 | **Não usar atribuição "by Claude"** na página do pitch/site | DECLARADO | Usuário |
| C-04 | Reformulação do site no branch **`reformulacao`** (a partir da `main`), **passo a passo** (ver código → plano → avaliar → executar), conferindo pela **prévia da Vercel** antes de unir à `main` | DECLARADO | Usuário |
| C-05 | Mockups usam **dados fictícios** (João Silva, Fazenda Santa Helena etc.), só ilustrativos | DECLARADO | Usuário |
| C-06 | **Commits** saem como o usuário **`Kadu-cell`**, com e-mail **noreply do GitHub**, **sem** `Co-Authored-By: Claude` | DECLARADO | Preferência do usuário |
| C-07 | Código do site no repositório privado `Kadu-cell/gadogest` (Vercel) | **SUBSTITUÍDA por D-11 em 16/11/2026** | Usuário |

## 3. Decisões de processo de engenharia (instruções ao Claude)

| ID | Decisão | Status |
|---|---|---|
| P-01 | Analisar a estrutura, ler os arquivos relevantes e verificar se a funcionalidade já existe **antes** de implementar | DECLARADO |
| P-02 | **Não presumir** que a documentação reflete o código | DECLARADO |
| P-03 | Respeitar a arquitetura; não reescrever módulos sem necessidade; não duplicar estruturas; não adicionar dependências desnecessárias | DECLARADO |
| P-04 | **Não descaracterizar a interface** existente; não alterar funcionalidades existentes sem justificativa | DECLARADO |
| P-05 | **Não considerar planejado como implementado**; sempre diferenciar existente × aprovado × proposta futura | DECLARADO |
| P-06 | Não implementar recursos pós-MVP sem alinhamento | DECLARADO |
| P-07 | Para problemas relevantes: causa → explicação → solução → arquivos afetados → riscos → **aguardar autorização** se a equipe pediu análise primeiro | DECLARADO |
| P-08 | Sem alterações destrutivas ou migrações arriscadas sem explicar consequências | DECLARADO |
| P-09 | **Não declarar concluído** só porque o código foi escrito; informar o que foi testado, resultados e o que falta validar; **não inventar resultados de testes nem estruturas de arquivos** | DECLARADO |
| P-10 | Considerar offline, sincronização e permissões por fazenda em toda mudança | DECLARADO |

## 4. Decisões técnicas — plano técnico v1.0 [PLANEJADO]

Todas sujeitas ao conflito T-00 (plataforma).

| ID | Decisão | Observação |
|---|---|---|
| T-01 | App mobile em **React Native + Expo**, Android primeiro | Conflita com Electron (ver K-01) |
| T-02 | **SQLite** como banco local; registros persistidos localmente antes de sincronizar | Em comum com a descrição do Project |
| T-03 | **PowerSync** para sincronização SQLite ↔ PostgreSQL | Custo ainda é pendência (Q-17) |
| T-04 | **Supabase** como backend: PostgreSQL, Auth, RLS, Edge Functions | |
| T-05 | Painel web em **Next.js + TypeScript**; no MVP pode ser só online | |
| T-06 | **TypeScript em todas as camadas** do MVP (recomendação do plano) | Confirmação da equipe pendente (Q-15) |
| T-07 | **Python** possível no futuro para análises/relatórios; **PHP fora** da arquitetura | |
| T-08 | **UUID gerado no dispositivo** para todo registro sincronizado | |
| T-09 | **Idempotência** no servidor: reenvio do mesmo UUID não duplica | |
| T-10 | Ações são **eventos históricos**, sem sobrescrever informação anterior | |
| T-11 | Isolamento por **`fazenda_id`** + **RLS** + regras de sincronização | |
| T-12 | **Exclusão lógica** (`apagado_em`); restauração explícita | |
| T-13 | **Status sanitário e GMD calculados**, não armazenados | |
| T-14 | **Brinco único por fazenda**; duplicidade offline detectada na sincronização e resolvida pelo gestor; **sem perda silenciosa** | Forma de resolução pendente (Q-19) |
| T-15 | Convenções: IDs UUID; `criado_em`/`atualizado_em`/`apagado_em`; ISO/UTC; exibição BR; **dinheiro em centavos**; **peso em kg, 1 casa decimal na apresentação** | |
| T-16 | Papéis iniciais **Gestor** e **Funcionário**; segurança aplicada no backend, não só na interface | Matriz pendente (Q-20) |
| T-17 | **Licença offline**: token assinado; chave privada só no servidor; verificação com chave pública no app; validade inicial **15 dias**; modo de consulta ao vencer; detecção de relógio retrocedido; revogação com apagamento de dados locais | Política ao vencer pendente (Q-18); ver tensão K-04 |
| T-18 | Entidades: Conta, Fazenda, Usuário, Vínculo, Aparelho, Lote, Animal, Pesagem, Evento sanitário, Manejo agendado, Movimentação, Evento reprodutivo, Lançamento financeiro, Categoria | |
| T-19 | Cronograma ~9 semanas em 8 etapas (0 a 7) | Estimativa; a revisar |
| T-20 | Estratégias de risco: UUID/idempotência/testes offline; RLS + testes automatizados; escopo enxuto; avisos de pendência; testes em Android simples; teste com produtores; detecção de brinco duplicado; monitoramento de custos | |

## 5. Decisão técnica declarada no Project (desktop)

| ID | Decisão | Status |
|---|---|---|
| T-00 | Aplicação **desktop** com **Electron, React, TypeScript, Tailwind CSS, Prisma ORM e SQLite**, priorizando funcionamento local, segurança, organização e facilidade de manutenção | **SUBSTITUÍDA por D-01 em 16/11/2026** |

## 5.1 Decisões tomadas no Claude Code

| ID | Decisão | Status | Data | Fonte/Quem decidiu | Substitui |
|---|---|---|---|---|---|
| D-01 | Plataforma: **app mobile (campo, Android primeiro) + painel web (gestor)**, conforme o plano técnico v1.0 (T-01 a T-05). Resolve K-01 e Q-21. As tecnologias específicas (Expo, Next.js, Supabase, PowerSync) seguem como PLANEJADO; PowerSync e criptografia do SQLite serão validados na Etapa 0. | DECIDIDO | 16/11/2026 | Usuário (Kadu), na primeira sessão do Claude Code | T-00 |
| D-02 | Login por **e-mail e senha** (Supabase Auth). Resolve Q-04. | DECIDIDO | 16/11/2026 | Usuário (Kadu) | — |
| D-03 | **Funcionário trabalha em uma única fazenda.** Resolve Q-07. Observação técnica: a tabela de vínculo usuário–fazenda continua no modelo (o gestor/conta pode ter mais de uma fazenda); a regra "funcionário = 1 fazenda" é aplicada como restrição. | DECIDIDO | 16/11/2026 | Usuário (Kadu) | — |
| D-04 | Aplicação sanitária em lote gera **um registro por animal**; o lote é só um atalho de lançamento. Resolve Q-08. | DECIDIDO | 16/11/2026 | Usuário (Kadu) | — |
| D-05 | **Financeiro básico fica fora do MVP.** Resolve Q-23 e K-08 para o MVP. | DECIDIDO | 16/11/2026 | Usuário (Kadu) | — |
| D-06 | **Brinco duplicado** após sincronização: os dois cadastros são mantidos e marcados como conflito; o **gestor decide** entre juntar (eventos passam para um só animal) ou corrigir o brinco de um deles. Nada é unido automaticamente nem perdido. Resolve Q-19. | DECIDIDO | 16/11/2026 | Usuário (Kadu) | — |
| D-07 | **Brinco opcional** no cadastro (ex.: bezerro recém-nascido): o animal entra com nome/apelido e identificador provisório exibido; a regra de brinco único por fazenda vale só quando o brinco está preenchido. Resolve Q-10. | DECIDIDO | 16/11/2026 | Usuário (Kadu) | — |
| D-08 | **Catálogo sanitário**: o app vem com lista inicial de vacinas/medicamentos comuns (conteúdo a ser montado pela veterinária da equipe) e o produtor pode cadastrar os seus. Resolve Q-11. | DECIDIDO | 16/11/2026 | Usuário (Kadu) | — |
| D-09 | **Exames ficam fora do MVP.** Resolve Q-24 e K-05 para o MVP. | DECIDIDO | 16/11/2026 | Usuário (Kadu) | — |
| D-10 | Código do sistema (app mobile + painel web + backend) no repositório **`GadoGest/gadogest-sistema`**, separado do site. Resolve K-07 e Q-29. | DECIDIDO | 16/11/2026 | Usuário (Kadu) | — |
| D-11 | Repositório do **site** (`gadogest.com.br`, Vercel) é **`GadoGest/gadogest-site`**. | DECIDIDO | 16/11/2026 | Usuário (Kadu) | C-07 |

Verificação de 16/11/2026: não há código do sistema no Google Drive (`BackEnd/`, `FrontEnd/` e `GadoGest-Arquitetura/` vazias). Nada está implementado (responde Q-22 para esta data).

---

## 6. Conflitos identificados

| ID | Conflito | O que fazer |
|---|---|---|
| **K-01** | **Plataforma/stack**: desktop Electron + Prisma + SQLite (Project) × mobile Expo + painel Next.js + Supabase + PowerSync (plano técnico). Também: Tailwind só no Project; sincronização, licença e aparelhos só no plano. | **RESOLVIDO em 16/11/2026 → D-01 (mobile + painel web)** |
| **K-02** | **Maturidade dos módulos**: Project diz que o sistema "possui módulos integrados" (inclui pessoas, alimentação, estoque, financeiro, relatórios, reprodução); plano diz que reprodução está fora do MVP, alimentação/estoque são "planejados", financeiro detalhado e relatórios avançados são pós-MVP | Auditar o código; tratar como "planejado" até confirmar |
| **K-03** | **Tamanho da equipe**: plano estima 9 semanas com "três pessoas"; equipe tem 4 integrantes, 1 desenvolvedor identificado | Confirmar quem desenvolve; rever cronograma |
| **K-04** | **Apagar dados locais de aparelho revogado** × regra de não perder registros silenciosamente: e os dados ainda não sincronizados? | Decidir política (ex.: bloquear/sincronizar antes?) — ver Q-18 e Q-19 |
| **K-05** | **Exames** como parte da sanidade aparecem só na descrição do Project; o plano técnico não os lista | Confirmar se entram no escopo |
| **K-06** | **Validação**: "6 de 8 entrevistados" (doc) × "12 fazendas" (usuário) | Confirmar se são levantamentos distintos antes de usar em materiais |
| **K-07** | **Local do código**: `Kadu-cell/gadogest` foi descrito como o repositório do **site**; não se sabe se o sistema está nele, em outro, ou não existe | **RESOLVIDO em 16/11/2026 → D-10** |
| **K-08** | **Financeiro**: Project lista como módulo integrado; plano coloca básico no painel "se confirmado" e detalhado pós-MVP; mockups de pitch mostram tela de Financeiro (dados fictícios) | Confirmar escopo real do financeiro no MVP |
| **K-09** | **Público**: Project diz "pequenos produtores"; doc inclui também pequeno e médio porte | Menor; tratar pequeno como prioridade |

---

## 7. Pendências (não inventar respostas)

As 20 questões do plano técnico, mais as derivadas.

| ID | Pergunta | Status |
|---|---|---|
| Q-01 | Os primeiros 30 clientes representam contas ou fazendas? | Aberta |
| Q-02 | Quantos animais tem a maior propriedade? | Aberta |
| Q-03 | Qual o orçamento mensal de infraestrutura? | Aberta |
| Q-04 | Login por e-mail ou telefone? | **Respondida 16/11/2026 → D-02** |
| Q-05 | Assinatura por conta ou por fazenda? | Aberta |
| Q-06 | Limite de aparelhos por conta ou por fazenda? | Aberta |
| Q-07 | Um funcionário pode trabalhar em várias fazendas? | **Respondida 16/11/2026 → D-03** |
| Q-08 | Aplicação em lote = um registro individual por animal? | **Respondida 16/11/2026 → D-04** |
| Q-09 | Cobrança manual ou automatizada (gateway)? | Aberta |
| Q-10 | Como identificar animais sem brinco? | **Respondida 16/11/2026 → D-07** |
| Q-11 | Produtos sanitários terão catálogo pré-cadastrado? | **Respondida 16/11/2026 → D-08** |
| Q-12 | Algum produtor piloto usa iPhone? | Aberta |
| Q-13 | Existem telas no Figma? | Aberta |
| Q-14 | Qual a experiência técnica de cada integrante? | Aberta |
| Q-15 | A equipe confirma TypeScript em todas as camadas? | Aberta |
| Q-16 | Qual solução para criptografia do SQLite? | Aberta |
| Q-17 | O custo do PowerSync é adequado ao orçamento? | Aberta |
| Q-18 | Qual a política de licença vencida? | Aberta |
| Q-19 | Como resolver duplicidade de brincos? | **Respondida 16/11/2026 → D-06** |
| Q-20 | Qual a matriz definitiva de permissões? | Aberta |

**Pendências adicionais (derivadas das lacunas e conflitos):**

| ID | Pergunta | Origem |
|---|---|---|
| Q-21 | Qual plataforma vale: desktop, mobile + web, ou ambas? | K-01 — **respondida em 16/11/2026: mobile + web (D-01)** |
| Q-22 | O que já está implementado no código? | K-02, K-07 |
| Q-23 | Financeiro básico no painel entra no MVP? | Doc §5.7, §11.1 — **respondida 16/11/2026 → D-05** |
| Q-24 | Exames entram no módulo de sanidade? | K-05 — **respondida 16/11/2026 → D-09** |
| Q-25 | Alimentação e estoque: escopo, prioridade e detalhamento? | Doc §7.8–7.9 |
| Q-26 | Política para dados locais não sincronizados em aparelho revogado | K-04 |
| Q-27 | Qual cobrança/plano substitui o valor de referência R$ 89,90? | Doc §15 |
| Q-28 | Como o orçamento do edital (drone, balança, carreta, RFID/etiquetas etc.) se relaciona ao roadmap, já que balança/RFID estão fora do MVP? | Orçamento do edital |
| Q-29 | Repositórios: site e sistema separados ou juntos? | K-07 — **respondida 16/11/2026 → D-10** |

---

## 8. Como registrar uma nova decisão

```
| ID | Decisão | Status | Data | Fonte/Quem decidiu | Substitui |
```
Mova itens de "Pendências"/"Conflitos" para as tabelas de decisões ao resolvê-los, citando a data. **Não apague decisões anteriores**; marque como substituídas e indique a nova.
