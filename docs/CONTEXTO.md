# CONTEXTO — GadoGest

> Histórico resumido, origem, equipe, justificativas e diferenciais. Fontes: documento central do Project (v1.0, nov/2026), descrição do Project e informações fornecidas pelo usuário em conversas anteriores.
>
> **Limitação:** o histórico completo das conversas do Project não estava disponível para leitura nesta migração; só o que consta nos documentos e nas informações salvas. Cronologia exata de várias etapas **não** está registrada. Onde faltam datas, isso é dito.

---

## 1. O que é

Plataforma de gestão de **gado de corte** para pequenos produtores rurais (e possivelmente propriedades de pequeno e médio porte), que troca cadernos, fichas e planilhas por uma solução digital centralizada, simples e **offline-first**. Tem como foco de valor a **saúde e a sanidade animal** e indicadores para decisão.

Nome comercial usado em materiais: **GadoGest — Sistema de Gestão de Gado de Corte**.

Natureza: startup acadêmica/empreendedora, em **estágio de protótipo**, concebida como **produto comercial por assinatura**.

---

## 2. Origem da ideia

- A ideia surgiu de **conversas com o avô de Pedro e com o tio de Isadora** sobre problemas reais da gestão rural.
- Escopo inicial discutido: gestão geral da fazenda, animais, localização de lotes, saúde animal, alimentação, reprodução, ganho de peso e financeiro.
- Depois, o foco foi **direcionado para saúde e sanidade animal**.
- O problema foi validado inicialmente com produtores, familiares envolvidos na pecuária e profissionais do setor.

### Validação
- Questionário: **6 de 8** entrevistados reconheceram o problema (validação inicial, não representativa do mercado — o próprio documento faz essa ressalva).
- O usuário também informou que a validação envolveu **12 fazendas**.
- **[A RECONCILIAR]** Não está registrado se os "8 entrevistados" e as "12 fazendas" são levantamentos distintos ou o mesmo. Não somar nem comparar sem confirmar.

---

## 3. Equipe

| Pessoa | Papel |
|---|---|
| Carlos Eduardo (Kadu) | Gestão (usuário GitHub: `Kadu-cell`) |
| Pedro Mariano Brito Vilela | Desenvolvedor |
| Onesio Da Costa Rosa Nunes | Marketing |
| Isadora Pereira Prado | Médica veterinária |

**[CONFLITO]** O plano técnico estima ~9 semanas "com uma equipe de três pessoas", mas a equipe do projeto tem quatro integrantes, apenas um identificado como desenvolvedor. A experiência técnica de cada integrante é uma **pendência** (pergunta 14 do plano). Não presumir quem desenvolve o quê.

O usuário deste Project é Carlos Eduardo (Kadu), que atua na área de engenharia de software e consta na equipe como responsável pela Gestão.

---

## 4. Evento e pitch (Agro Startup)

- O GadoGest participa do **Agro Startup**: cerca de 36 equipes, apresentações de 5 minutos, meta de ficar entre as 12 melhores. "**Inovar para Cuidar**" é o **tema do evento**, não um slogan do GadoGest.
- Pitch planejado: ~3 minutos, 10 slides, depois versão PDF de até 5 minutos; interativo e profissional, com imagens rurais reais e dashboards em verde-escuro e branco.
- Página de apresentação acessada por **QR Code, sem login**, em React + Vite, publicada via GitHub + Vercel. Foi feita com Claude e Lovable; a atribuição "by Claude" precisou ser retirada.
- Em **24/10/2026**, o rodapé de créditos do QR Code estava pronto; faltava só uma ideia para completar os créditos finais.
- Slogans próprios: *"GadoGest: Onde a eficiência vira arroba."*; *"GadoGest: Inteligência no manejo, precisão no resultado."*; *"Quem controla os dados do rebanho, controla o futuro da produção."*; *"O campo produz riqueza. O GadoGest transforma informação em resultado."*
- Materiais visuais: foto da equipe com polos verde-escuras com a logo; frase "Que a GadoGest seja o começo de algo grande! 🚀"; wallpapers para PC e celular planejados.

### Mockups de dashboard (apenas ilustrativos)
Verde-escuro e branco, menu lateral esquerdo, 1536×1024. Usuário demo "João Silva", propriedade demo "Fazenda Santa Helena". Telas: Animais (245 cadastrados, ex.: "Turbo 0012", 520 kg), Ficha do animal, Saúde Animal (210 vacinados, 86%, 18 atrasadas, 10 em tratamento, 7 sem registro), Financeiro (abr/2025: receitas R$ 38.200, despesas R$ 9.750, saldo R$ 28.450). **Todos os dados são fictícios.**

---

## 5. Financiamento / edital (informado pelo usuário)

Não faz parte do produto, mas é contexto de negócio:
- GadoGest **não tem endereço comercial real definido**.
- Orçamento de referência para edital: **R$ 60.000** (capital + custeio preferido R$ 50.000–55.000; contrapartida mínima R$ 2.962,01). Itens: drone (até R$ 6.000), balança, carreta adaptada para pesagem, impressora de etiquetas, nobreak para NAS, HD externo, tablet, equipamentos de rede/armazenamento; **sem notebook e sem endereço de empresa**.
- Limites do formulário: descrição da atividade até 200 caracteres; descrição da despesa até 60 caracteres.
- Não há, nas fontes, decisão de como esses equipamentos se ligam ao roadmap técnico (ex.: balança/RFID estão **fora do MVP**).

---

## 6. Documento central e plano técnico

Em **novembro de 2026** foi redigido o documento "GadoGest — Contexto Central do Projeto" (v1.0) para dar ao Claude uma visão abrangente do projeto. Ele contém: visão, problema, público, proposta de valor, arquitetura técnica proposta, princípios, estrutura funcional, modelo de dados, segurança, licença offline, escopo do MVP, cronograma (~9 semanas), riscos, diretrizes de interface, modelo de negócio, **20 pendências** e instruções de trabalho para o Claude. Ele próprio pede que seja atualizado conforme decisões forem tomadas e que se diferencie sempre **planejado × aprovado × existente**.

O Project (descrição) define o papel do Claude: engenheiro experiente, arquiteto e parceiro técnico — **analisar antes de alterar, não descaracterizar a interface, não confundir planejado com implementado**.

---

## 7. Diferenciais e justificativas

| Diferencial | Justificativa (nas fontes) |
|---|---|
| **Offline-first** | Conectividade limitada em regiões rurais; o curral não pode depender de internet; registros locais sincronizam depois |
| **Simplicidade** | Público com pouca familiaridade digital; funcionário de campo precisa registrar rápido, em poucos passos |
| **Foco em sanidade** | Maior dor: registros sanitários desorganizados, difícil rastrear vacinas, medicamentos, tratamentos e carências |
| **Histórico individual por eventos** | Rastreabilidade; nunca sobrescrever o passado |
| **Isolamento por fazenda e permissões** | Segurança dos dados; gestor × funcionário |
| **Acessível para pequenos produtores** | Mercado carente de ferramentas simples e baratas |
| **Pensado na realidade do produtor** | O produtor não deve se adaptar a uma ferramenta complexa (ex.: persona Aglauto, que pode estimar peso por fita) |
| **Evolução gradual** | MVP enxuto e confiável primeiro; inteligência, financeiro detalhado e integrações depois |

---

## 8. Modelo de negócio

- Produto comercial por **assinatura**. Mensalidade de **referência: R$ 89,90** (usada no planejamento técnico).
- **Em aberto:** cobrança por conta ou por fazenda; aparelhos incluídos; planos diferentes; controle de assinatura; cobrança manual ou via gateway; política para licença vencida. Nada disso deve ser tratado como definido.

---

## 9. Histórico resumido (ordem aproximada; datas só onde conhecidas)

1. Conversas com a família de Pedro e de Isadora revelam problemas reais da gestão rural.
2. Definição de escopo amplo (fazenda, animais, lotes, saúde, alimentação, reprodução, peso, financeiro).
3. Redirecionamento do foco para saúde e sanidade.
4. Validação inicial com produtores e profissionais (questionário 6/8; 12 fazendas).
5. Identidade de equipe e comunicação: slogans, polos, wallpapers, mockups.
6. Participação no Agro Startup; pitch e página de QR Code (React + Vite, Vercel). Créditos do rodapé prontos em 24/10/2026.
7. Preparação de orçamento para edital.
8. Nov/2026: documento central v1.0 / plano técnico com arquitetura mobile + web.
9. Reformulação do site combinada em branch dedicado (`reformulacao`), ainda sem data de início registrada; em 16/11/2026, preparação da migração do contexto do Project para o Claude Code.

*A ordem entre itens 4–7 não está registrada com precisão.*

---

## 10. Pontos de atenção de contexto

- O Project descreve uma aplicação **desktop (Electron)**, enquanto o plano técnico descreve **mobile + web**. Ver `CLAUDE.md` §1 e `DECISOES.md`.
- A "ideia de mobile para o campo + painel web" aparece nos materiais de proposta de valor; a "aplicação desktop" aparece apenas na descrição do Project.
- O site, a página de pitch e o app podem estar em repositórios diferentes. **[A VERIFICAR]**
