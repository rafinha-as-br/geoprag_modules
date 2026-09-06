# GEOPRAG-101

Estado: EM_EXECUÇÃO
Repositório: geoprag_modules
Branch: feat/GEOPRAG-101-claude (nova, a partir de develop @ 886554b)

## Objetivo atual / contexto de retomada
Seleção múltipla genérica no BaseListScreen (checkbox por linha, "selecionar
todos", barra de ações em lote) + ações em lote Ativar/Desativar/Atribuir
aplicador na tela de Bairro (Gestão de Aplicações). Ativar em lote inclui
agendamento (data 1ª aplicação, intervalo, recorrências) — decisão tomada
com Rafinha (2026-09-06): modelar como `Agendamento`/`DataAgendada`
persistidos na entidade `PontoDeAplicacao` (lista de datas, cada uma com
status próprio, editável individualmente depois — não uma fórmula
calculada on-the-fly), análogo a como `Subponto` já é modelado.

## Próxima ação
Implementação, autorevisão (flutter-development-standards) e code review
(/code-review medium) concluídos. Gate de qualidade (flutter analyze +
flutter test) passou. Próxima ação: commit + push + abrir PR (5.5/5.6).

## Não repetir
- Já pesquisado a fundo (Explore + leitura direta): `BaseListScreen`,
  `GeopragDataTable`, `AplicadoresCubit`/`dashboard_aplicadores_screen.dart`
  (precedente funcional de seleção em massa, não generalizado),
  `PontoDeAplicacao`, `AdminPontoDeAplicacaoRepository`(Impl),
  `ponto_de_aplicacao_colunas.dart`, `AcaoFeedback`,
  `base_list_screen_test.dart`. Não repetir essa exploração.

## Decisões técnicas
- Agendamento como lista de datas persistida na entidade (confirmado com
  Rafinha, não presumido).
- "Desativar" em lote transiciona para `EstadoPontoDeAplicacao.desativado`
  (não `inativa` — são estados distintos; `inativa` já é uma origem válida
  de Desativar, o que descarta `inativa` como alvo). "Reativar" (voltar ao
  estado anterior) fica fora do escopo da GEOPRAG-101 — pertence à
  GEOPRAG-110, que precisará decidir como lembrar o estado anterior.
- Elegibilidade (estado de origem válido) é checada localmente (dados já
  carregados na tela), antes de chamar o repository — não é round-trip.
- Falha de execução real (rara, já elegível) segue "sucesso total / parcial
  com retry do que falhou / falha total", via `BatchProgressDialog`.

## Bloqueios / decisões pendentes de Rafinha
Nenhum (decisão de modelagem do agendamento já resolvida via AskUserQuestion
em 2026-09-06, antes de começar a implementação).

## Última atualização
2026-09-06 (início da implementação)
