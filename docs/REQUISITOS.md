# REQUISITOS — GadoGest

> Fonte principal: documento central do Project (v1.0, nov/2026) e descrição/instruções do Project. Os requisitos abaixo **não estão confirmados como implementados**. Ver legenda em `CLAUDE.md` (§0).
>
> Os IDs (RF-xxx, RNF-xxx, RN-xxx) foram criados apenas para organizar e referenciar; o conteúdo vem das fontes. Nada aqui deve ser lido como funcionalidade existente sem verificar o código.

---

## 1. Escopo e status por módulo

Os dois textos-fonte listam módulos de forma diferente. A tabela os confronta.

| Módulo | Descrição do Project (desktop) | Plano técnico v1.0 | Status no plano |
|---|---|---|---|
| Fazendas | citado | Fazendas, seleção de fazenda, configurações | MVP |
| Pessoas / usuários | "pessoas" | Usuários, vínculos, papéis | MVP |
| Animais (Rebanho) | citado | Cadastro, ficha individual, status | MVP |
| Lotes | citado | Criar, editar, transferir | MVP |
| Pesagens | citado | Pesagem individual/lote, histórico, GMD, gráficos | MVP |
| Movimentações | citado | Nascimento, compra, venda, morte, troca de lote | MVP |
| Saúde e sanidade | "sanidade" (vacinas, medicamentos, tratamentos, **exames**) | Vacinas, medicamentos, tratamentos, ocorrências, calendário, alertas | MVP (módulo mais importante) |
| Manejos agendados | não citado | Agendar, recorrência, alertas, atrasos | MVP |
| Dashboard | citado | Indicadores gerais no painel | MVP (painel) |
| Reprodução | citado | Previsto para evolução | **Fora do MVP** |
| Alimentação | citado | "Módulo planejado" | Planejado (sem detalhe) |
| Estoque | citado | "Módulo planejado" | Planejado (sem detalhe) |
| Financeiro | citado | Básico no painel *se confirmado*; detalhado em versões posteriores | Parcial no MVP / detalhado pós-MVP |
| Relatórios | citado | Relatórios avançados e exportáveis fora do MVP | Pós-MVP |
| Licença e aparelhos | não citado | Licença offline, gestão de aparelhos | MVP (Etapa 6) |

**[CONFLITO]** A descrição do Project diz que o sistema "possui módulos integrados" para todos os itens acima; o plano técnico trata vários como planejados ou pós-MVP. Pela regra do projeto, **não considerar funcionalidade planejada como já implementada**. Verificar o código.

---

## 2. Requisitos funcionais

### 2.1 Autenticação, contas, fazendas e permissões
- **RF-AUT-01** Login e autenticação de usuários.
- **RF-AUT-02** Seleção de fazendas no app (um usuário pode precisar alternar entre fazendas). *[PENDENTE: um funcionário pode trabalhar em várias fazendas?]*
- **RF-AUT-03** Papéis iniciais: **Gestor** e **Funcionário** (matriz de permissões **decidida em 19/11/2026**: D-17, D-26 e D-37 em `docs/DECISOES.md`; o funcionário usa só o app e não acessa o painel web).
  - Gestor: gerenciar a propriedade, administrar usuários, gerenciar aparelhos, acessar informações gerenciais, consultar financeiro conforme permissões.
  - Funcionário: acessar informações operacionais autorizadas, registrar atividades de campo, consultar animais e históricos permitidos; **não vê financeiro** quando essa restrição estiver configurada.
- **RF-AUT-04** Gerenciamento de usuários e vínculos usuário–fazenda (painel).
- **RF-AUT-05** Gerenciamento de aparelhos autorizados (painel).
- **RF-AUT-06** Configurações da propriedade (painel).
- *[PENDENTE]* Login por e-mail ou telefone.

### 2.2 Rebanho (animais)
- **RF-ANI-01** Cadastro de animais com: brinco, nome, raça, sexo, categoria, data de nascimento, peso ao nascer, origem, foto, lote.
- **RF-ANI-02** Ficha/histórico individual do animal.
- **RF-ANI-03** Status do animal: **Ativo, Vendido, Morto**.
- **RF-ANI-04** Consulta de animais no app e no painel.
- **RF-ANI-05** Detecção e resolução de **brinco duplicado** (ver RN-05).
- *[PENDENTE]* Como identificar animais **sem brinco**.

### 2.3 Lotes
- **RF-LOT-01** Criar e editar lotes.
- **RF-LOT-02** Consultar animais do lote.
- **RF-LOT-03** Transferir animais entre lotes.
- **RF-LOT-04** Consultar movimentações do lote.
- **RF-LOT-05** Organizar manejos coletivos.

### 2.4 Pesagens e desempenho
- **RF-PES-01** Pesagem individual.
- **RF-PES-02** Pesagem em lote.
- **RF-PES-03** Histórico de pesagens e evolução do peso.
- **RF-PES-04** **Cálculo de GMD** com base nas pesagens válidas e no intervalo entre elas (calculado, não armazenado).
- **RF-PES-05** Gráficos de desempenho.
- **RF-PES-06 (evolução futura)** Estimativas por fita de pesagem, sempre sinalizadas como estimativa.

### 2.5 Saúde e sanidade (módulo prioritário)
- **RF-SAN-01** Registro de vacinas, medicamentos, tratamentos e ocorrências.
- **RF-SAN-02** Campos: dose, via de aplicação, data de aplicação, período de carência, fim do tratamento.
- **RF-SAN-03** Histórico sanitário individual.
- **RF-SAN-04** Aplicação individual **ou em lote**. *[PENDENTE: aplicação em lote vira um registro individual por animal?]*
- **RF-SAN-05** Manejos agendados, alertas e calendário sanitário.
- **RF-SAN-06** Facilitar a consulta do histórico e a recuperação de informações sobre medicamentos e vacinas usados.
- **RF-SAN-07** Painel web: consulta sanitária.
- **RF-SAN-08** *(Project, desktop)* Exames como parte do histórico sanitário. Não aparece no plano técnico v1.0 — **[CONFLITO leve]**; confirmar escopo.
- *[PENDENTE]* Se haverá catálogo pré-cadastrado de produtos sanitários.
- Restrição: o sistema **não substitui diagnóstico, prescrição ou orientação veterinária**.

### 2.6 Manejos agendados
- **RF-MAN-01** Agendar manejo e associá-lo a animal ou lote.
- **RF-MAN-02** Definir data prevista e recorrência.
- **RF-MAN-03** Marcar como realizado; cancelar.
- **RF-MAN-04** Gerar alertas e identificar manejos atrasados.

### 2.7 Movimentações
- **RF-MOV-01** Tipos: nascimento, compra, venda, morte, troca de lote.
- **RF-MOV-02** Preservar o histórico e **atualizar corretamente a situação atual** do animal.

### 2.8 Reprodução (fora do MVP)
- **RF-REP-01** Cobertura, inseminação artificial, diagnóstico, parto, aborto, associação matriz–bezerro, histórico reprodutivo.

### 2.9 Alimentação e estoque (planejados, sem detalhamento)
- **RF-ALI-01** Organizar informações de alimentação e manejo alimentar. *Detalhamento não definido.*
- **RF-EST-01** Controle de insumos e produtos usados na propriedade. *Detalhamento não definido.*

### 2.10 Financeiro
- **RF-FIN-01** Receitas e despesas; categorias; valores pagos e pendentes; saldo mensal; custos por animal; histórico de lançamentos.
- Status: **financeiro detalhado é pós-MVP**; um **financeiro básico no painel** só se for confirmado no escopo final. Em caso de atraso, é o **primeiro item a ser adiado**.
- Funcionário não vê financeiro quando restrição configurada (RF-AUT-03).

### 2.11 Dashboard e indicadores
- **RF-DSH-01** Indicadores importantes da propriedade para entender rapidamente a situação do rebanho.
- **RF-DSH-02** Priorizar informação útil para decisão; evitar excesso de dados sem utilidade prática.
- *(Exemplos de indicadores nos mockups de pitch, **dados fictícios**: total de animais, vacinados %, vacinas atrasadas, em tratamento, sem registro, receitas/despesas/saldo.)*

### 2.12 Alertas
- **RF-ALE-01** Alertas de manejos programados e atrasados no app.
- **RF-ALE-02** Avisos de pendências de sincronização (ver RNF-OFF-05).

### 2.13 Licença offline e aparelhos
- **RF-LIC-01** O servidor emite token assinado; o app valida com chave pública (a chave privada nunca fica no app).
- **RF-LIC-02** A licença contém fazenda, aparelho, emissão e validade; **validade inicial proposta: 15 dias**.
- **RF-LIC-03** Ao vencer, o app entra em **modo de consulta**, conforme regras comerciais aprovadas **[PENDENTE: política de licença vencida]**.
- **RF-LIC-04** Detectar retrocesso indevido do relógio.
- **RF-LIC-05** Aparelhos revogados têm dados locais apagados na próxima conexão, respeitando procedimentos de segurança **[TENSÃO: ver DECISOES.md, K-04]**.
- **RF-LIC-06** Gestão de aparelhos autorizados.

### 2.14 Painel web
- Dashboard; indicadores gerais; consulta de animais; informações sanitárias; usuários; aparelhos; configurações da propriedade; financeiro básico (se mantido); relatórios/informações gerenciais conforme evolução.
- No MVP, o painel **pode funcionar exclusivamente online**.

---

## 3. Regras de negócio e de dados

- **RN-01** Todo registro operacional pertence a uma fazenda (`fazenda_id`).
- **RN-02** Eventos (vacinação, medicamento, tratamento, pesagem, ocorrência, nascimento, compra, venda, morte, troca de lote) são históricos e **não sobrescrevem** o anterior.
- **RN-03** Status sanitário e GMD são **calculados**; não armazenar derivados que possam ficar desatualizados.
- **RN-04** Exclusão lógica via `apagado_em`; restauração é ação explícita.
- **RN-05** **Brinco único por fazenda.** Dois aparelhos offline podem cadastrar o mesmo brinco; após sincronizar, o sistema identifica a duplicidade e apresenta situação para o gestor resolver. **Nenhum registro se perde silenciosamente.** *[PENDENTE: forma de resolução]*
- **RN-06** Reenvio do mesmo UUID não cria duplicata (idempotência).
- **RN-07** Movimentações atualizam corretamente a situação atual do animal preservando histórico.
- **RN-08** Estimativa de peso (fita) ≠ medição em balança; sempre indicar.
- **RN-09** Convenções: UUID; `criado_em`, `atualizado_em`, `apagado_em`; autoria/aparelho quando aplicável; datas ISO/UTC no armazenamento e formato brasileiro na exibição; **valores monetários em centavos**; **peso em kg com uma casa decimal na apresentação**.

### Entidades do modelo de dados [PLANEJADO]

| Entidade | Finalidade |
|---|---|
| Conta | Cliente e assinatura |
| Fazenda | Propriedade rural |
| Usuário | Quem acessa |
| Vínculo | Usuário ↔ fazenda |
| Aparelho | Dispositivos autorizados |
| Lote | Agrupa animais |
| Animal | Cadastro individual do bovino |
| Pesagem | Histórico de peso |
| Evento sanitário | Histórico de saúde |
| Manejo agendado | Atividades futuras |
| Movimentação | Histórico de movimentações |
| Evento reprodutivo | Histórico reprodutivo |
| Lançamento financeiro | Receitas e despesas |
| Categoria | Classificação financeira |

*(O desenho de tabelas/campos além disso não consta nas fontes e não deve ser presumido. O app desktop descrito pelo Project usa Prisma — [A VERIFICAR] o schema real.)*

---

## 4. Requisitos não funcionais

### Offline e sincronização
- **RNF-OFF-01** O app **nunca** exige internet para registrar atividade de campo.
- **RNF-OFF-02** Persistência local (SQLite) antes de depender de sincronização.
- **RNF-OFF-03** Sincronização automática quando a conexão volta; registros entram em fila.
- **RNF-OFF-04** O servidor processa sem duplicar (UUID + idempotência).
- **RNF-OFF-05** Avisos de pendência de sincronização (mitiga perda de dados locais) e **indicador de sincronização** na interface.
- **RNF-OFF-06** A sincronização respeita permissões e vínculos usuário–fazenda.

### Segurança
- **RNF-SEG-01** Controle de acesso por usuário e fazenda, aplicado **no backend** (RLS no plano técnico).
- **RNF-SEG-02** Isolamento total entre fazendas, com testes automatizados.
- **RNF-SEG-03** Nenhum segredo privado no app (licença).
- **RNF-SEG-04** Criptografia do SQLite local **[PENDENTE: solução]**.
- **RNF-SEG-05** Descarte seguro de dados locais em aparelho revogado.

### Desempenho e plataformas
- **RNF-PER-01** Bom desempenho em **dispositivos Android simples**.
- **RNF-PLT-01** **Android é a primeira plataforma**; iOS fora do MVP *(pendente: algum produtor piloto usa iPhone?)*.

### Usabilidade e interface
- **RNF-UX-01** Interface simples para produtores com pouca familiaridade digital; botões grandes; poucos passos; textos objetivos; navegação simples; boa legibilidade; hierarquia visual clara; feedback imediato.
- **RNF-UX-02** Uso adequado ao campo (curral).
- **RNF-UX-03** Identidade em tons de verde; consistência entre app e painel; não parecer sistema administrativo genérico.
- **RNF-UX-04** Datas e formatos brasileiros; textos em português BR.

### Qualidade e manutenção
- **RNF-QUA-01** Código limpo e legível; TypeScript consistente; sem estruturas duplicadas.
- **RNF-QUA-02** Testes para: offline; sincronização; idempotência; permissões; isolamento entre fazendas; cadastro/movimentação de animais; eventos sanitários; lote; GMD; exclusão lógica; licenciamento; desempenho em dispositivos modestos.
- **RNF-QUA-03** Compatibilidade com a arquitetura atual; evitar dependências desnecessárias.

### Custos e negócio
- **RNF-CUS-01** Monitorar custo dos serviços e avaliar alternativas (ex.: custo do PowerSync vs. orçamento **[PENDENTE]**).

---

## 5. Fora do MVP (consolidado)

Reprodução completa · troca de dados por QR Code · troca de dados por Bluetooth · financeiro detalhado · relatórios avançados e exportáveis · cobrança automática · aplicativo iOS · integração com balanças · integração com RFID.

Também sem detalhamento definido: alimentação, estoque, "recomendações de manejo" e "inteligência aplicada" (visão de futuro).

---

## 6. Requisitos do site/página institucional (projeto relacionado)

Não é o sistema, mas consta no contexto:
- Domínio `gadogest.com.br`; código em `GadoGest/gadogest-site`; deploy na Vercel.
- Reformulação planejada: página nova, mudando quase tudo, **passo a passo** (ver código → montar plano → avaliar o que funciona → só então executar), no branch `reformulacao`, conferindo pela prévia da Vercel antes de unir à `main`.
- Página de apresentação (pitch) acessada por **QR Code, sem login**, em React + Vite, com visual profissional em **verde-escuro e branco**.
- Sem atribuição "by Claude".
