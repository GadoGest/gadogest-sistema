# ROADMAP — GadoGest

> Situação em **16/11/2026**, conforme as fontes do Project. **O código não foi inspecionado**; tudo que depende dele está marcado **[A VERIFICAR]**. Não tratar nada de "Planejado" como existente.

---

## 1. O que já existe / foi produzido (confirmado pelas fontes)

| Item | Observação |
|---|---|
| Documento central v1.0 / plano técnico (nov/2026) | Arquitetura, escopo do MVP, cronograma, riscos, 20 pendências |
| Validação inicial do problema | Questionário (6 de 8) e validação com 12 fazendas (a reconciliar) |
| Equipe definida | 4 integrantes (Gestão, Dev, Marketing, Veterinária) |
| Identidade de comunicação | Slogans, camisetas, textos, paleta verde-escuro/branco |
| Mockups de dashboard | Animais, Ficha do animal, Saúde Animal, Financeiro — **dados fictícios** |
| Página de apresentação por QR Code (pitch) | React + Vite, Vercel; créditos do rodapé prontos em 24/10/2026 |
| Site `gadogest.com.br` | Publicado; repositório `GadoGest/gadogest-site` na Vercel |
| Configuração do Project no Claude | Descrição, instruções e documento central |

---

## 2. Sistema (aplicação) — estado do código

**[A VERIFICAR — prioridade zero].** A descrição do Project afirma que o sistema "possui módulos integrados" e "está sendo desenvolvido como software desktop" (Electron/React/TS/Tailwind/Prisma/SQLite). O plano técnico descreve uma arquitetura diferente (mobile + web) como **planejada**. Não há, nas fontes, lista do que está implementado.

Checklist para a primeira sessão no Claude Code (apenas leitura):
- [x] Localizar o repositório do sistema → `GadoGest/gadogest-sistema` (16/11/2026; continha só um README).
- [x] Verificação de 16/11/2026: nenhum código do sistema existe ainda; desenvolvimento parte do zero.
- [ ] Identificar a stack real (`package.json`, Electron? Expo? Next.js? Prisma schema?).
- [ ] Listar módulos efetivamente existentes × planejados (fazendas, pessoas, animais, pesagens, lotes, movimentações, sanidade, reprodução, alimentação, estoque, financeiro, relatórios, dashboard).
- [ ] Verificar se há sincronização, licença, aparelhos, RLS.
- [ ] Verificar testes existentes e como rodá-los.
- [ ] Reportar ao usuário e atualizar este arquivo.

Nenhuma linha de módulo abaixo deve ser marcada "feito" sem essa verificação.

---

## 3. Em andamento

| Item | Detalhe |
|---|---|
| Reformulação do site | Transformar em página nova, mudando quase tudo, **passo a passo**: ver o código → montar um plano → avaliar o que funciona → executar. Trabalho no branch `reformulacao` (a partir da `main`), conferindo pela prévia da Vercel antes de unir à `main`. |
| Pitch / Agro Startup | Pitch de ~3 min (10 slides) e versão PDF de até 5 min; créditos finais ainda precisavam de uma ideia (em 24/10) |
| Orçamento para edital | Referência R$ 60.000; ajustes de itens e limites de caracteres do formulário |
| Migração para o Claude Code | Esta documentação |
| Resolução das 20 pendências do plano técnico | Em aberto (ver `DECISOES.md`) |

---

## 4. A desenvolver — plano técnico v1.0 [PLANEJADO]

Cronograma original: ~**9 semanas**, equipe de 3 pessoas. **Substituído em 16/11/2026 (D-20): sem data fixa**, etapa por etapa, com 2 desenvolvedores. Meta de desempenho da Etapa 2 passa a ser 5.000 animais (D-18); foto do animal sai do MVP (D-24). Prioridade: entregar um produto **confiável**; se atrasar, o **financeiro do painel é o primeiro a sair**.

| Etapa | Entrega | Status |
|---|---|---|
| 0 | Fundação e prova técnica do offline | Planejada |
| 1 | Login, contas, fazendas e permissões | Planejada |
| 2 | Rebanho, lotes e movimentações | Planejada |
| 3 | Saúde, sanidade e manejos | Planejada |
| 4 | Pesagens e GMD | Planejada |
| 5 | Painel web | Planejada |
| 6 | Licença offline e aparelhos | Planejada |
| 7 | Piloto e ajustes | Planejada |

*"Status" de cada etapa em relação ao código: [A VERIFICAR].* A Etapa 0 (prova técnica do offline) é uma porta de decisão: valida PowerSync/SQLite/criptografia antes do resto.

### Pós-MVP (não implementar sem alinhamento)
Reprodução completa · QR Code e Bluetooth para troca de dados · financeiro detalhado · relatórios avançados/exportáveis · cobrança automática · app iOS · integração com balanças · integração com RFID.

Planejados sem detalhamento: alimentação, estoque.

### Visão de longo prazo
Inteligência aplicada ao rebanho, análises de desempenho, recomendações de manejo, gestão financeira completa, integrações com equipamentos rurais. Python possível para análises/relatórios.

---

## 5. Riscos do plano (e estratégias)

| Risco | Estratégia |
|---|---|
| Falha na sincronização | UUID, idempotência, testes offline |
| Vazamento entre fazendas | RLS e testes automatizados |
| Prazo curto | Escopo enxuto, entregas graduais |
| Perda de dados locais | Avisos de pendências e sincronização |
| Baixo desempenho | Testes em Android simples |
| Dificuldade de uso | Interface simples e testes com produtores |
| Brincos duplicados | Detecção e resolução explícita |
| Custo dos serviços | Monitorar custos; avaliar alternativas |

---

## 6. Próximas etapas

### 6.1 Já decididas ou combinadas
1. Reformulação do site no branch `reformulacao`, passo a passo, com prévia da Vercel antes do merge.
2. Concluir pitch e materiais do Agro Startup.

### 6.2 Sugeridas para discussão (propostas deste documento, **não** são decisões)
1. **Auditoria somente-leitura do repositório** e relatório "existe × planejado" (§2).
2. **Resolver o conflito de plataforma** (desktop × mobile+web) com o usuário e registrar em `DECISOES.md`.
3. **Responder as pendências críticas** que bloqueiam o desenho: login (e-mail/telefone), assinatura (conta/fazenda), funcionário em várias fazendas, aplicação em lote, resolução de brinco duplicado, criptografia do SQLite, custo do PowerSync, matriz de permissões.
4. Se a arquitetura mobile+web for confirmada: executar a **Etapa 0** (prova técnica do offline) antes de investir nas demais.
5. Revisar o **cronograma** à luz da equipe real e da experiência técnica de cada integrante.
6. Definir se o repositório do site e o do sistema ficam separados.
7. Manter `CLAUDE.md` e `docs/` atualizados a cada decisão.
