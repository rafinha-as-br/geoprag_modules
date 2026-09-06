# GEOPRAG-110

Estado: EM_EXECUÇÃO
Repositório: geoprag_modules (+ app_administrador, se rota/UI exigir)
Branch: feat/GEOPRAG-110-claude, criada a partir de **feat/GEOPRAG-101-claude**
(não de develop) — decisão deliberada: o próprio texto da issue diz que o
modal de Ativação/Agendamento é "o mesmo componente usado no lote da issue
GEOPRAG-101", que ainda não foi mergeada em develop (PR #68 aberto, aguardando
Análise - Rafinha). Branch empilhada (stacked) sobre a 101 para reaproveitar
`Agendamento`/`DataAgendada`/repository/`BatchReconcileDialog` sem duplicar.
Quando a 101 mergear, o PR desta issue pode ser re-targetado para develop.

## Objetivo atual / contexto de retomada
Três sub-fluxos, todos sobre PontoDeAplicacao individual (não em lote):
1. Ativação/Agendamento (modal reaproveitando o formulário de agendamento da
   GEOPRAG-101) + transição automática para Inativa ao concluir a última
   recorrência (derivada na leitura — decisão registrada abaixo).
2. Atribuir/Desatribuir aplicador (modal com busca por nome, contagem de
   pontos já atribuídos).
3. Desativar/Reativar (qualquer estado → desativado; reativar volta ao
   estado anterior — exige lembrar o estado anterior na entidade, que hoje
   não existe).

## Próxima ação
Implementação, autorevisão e code review concluídos (achado real corrigido:
setState chamado durante build ao extrair FormularioDeAgendamento — só
apareceu rodando a suíte completa, não o arquivo isolado). Gate de qualidade
passou. Próxima ação: commit + push + abrir PR (5.5/5.6).

## Decisões técnicas
- Reativar exige lembrar o estado anterior: adicionar
  `PontoDeAplicacao.estadoAnterior` (nullable), preenchido por `desativar()`
  e consumido/limpo por `reativar()` (método novo).
- Ao desativar um ponto com agendamento vigente, as datas `pendente` do
  agendamento viram `cancelada` (status já existia desde a GEOPRAG-101, sem
  uso até agora — confirma que o modelo já previu este caso).
- "Transição automática para Inativa ao cumprir a última recorrência":
  computada como getter puro na entidade (todas as datas do agendamento
  concluídas) e aplicada na leitura pelo repository (`listar`/
  `listarPorBairro`/`buscarPorId`) — não persistida imediatamente. Documentar
  isso já que a issue pede explicitamente essa decisão. Como não existe
  ainda nenhum fluxo que marque uma `DataAgendada` como `concluida`
  (isso é da GEOPRAG-111/aplicador, não implementada), este caminho fica
  coberto por teste direto na entidade, não end-to-end.

## Bloqueios / decisões pendentes de Rafinha
Nenhum até o momento.
