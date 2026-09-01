Estado: EM_EXECUÇÃO

Issue: GEOPRAG-129 — Investigar ausência de scroll na listagem de aplicadores
com volume grande de dados
Repo: geoprag_modules
Branch: fix/GEOPRAG-129-claude (nova, a partir de develop)

Investigação: DashboardAplicadoresScreen (lib/portal_administrador/
gerenciamento_de_aplicadores/presentation/dashboard_aplicadores_screen.dart)
monta o body como Padding > Column (sem scroll) contendo o Card com a
GeopragDataTable — e GeopragDataTable é um `Table` puro, sem scroll
embutido. Nenhum ancestral (AdminScaffold.body é usado direto, sem
SingleChildScrollView) provê scroll. Confirmado: bug real, não só aparência.

Nota: BaseListScreen (template compartilhado, usado pelas outras 5 telas
migradas) tem a MESMA estrutura sem SingleChildScrollView — mas está fora do
escopo desta issue (a Observação da issue já registra que o bug, se
confirmado, é específico desta tela; dashboard_aplicadores_screen ficou fora
da migração ao BaseListScreen por causa da seleção em massa + chips,
acompanhamento em GEOPRAG-101). Fix aqui é local a esta tela.

Plano:
1. Aumentar mock_aplicadores.dart com mais entradas (volume suficiente pra
   gerar lista longa).
2. Envolver o body de DashboardAplicadoresScreen num SingleChildScrollView.
3. Teste de regressão: pump com lista grande em viewport pequeno, sem
   overflow.

Próxima ação: implementar, testar, autorevisão/code review, commit.
