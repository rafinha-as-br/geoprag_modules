Estado: EM_EXECUÇÃO

Issue: GEOPRAG-130 — Mover ações do aplicador selecionado para o topo da
listagem
Repo: geoprag_modules
Branch: feat/GEOPRAG-130-claude (nova, a partir de develop)

Local: lib/portal_administrador/gerenciamento_de_aplicadores/presentation/
dashboard_aplicadores_screen.dart, classe _DashboardConteudo. Hoje a ordem é:
chips de filtro → GeopragDataTable → (se houver seleção) _BarraAcaoEmMassa.
Objetivo: mover _BarraAcaoEmMassa para ANTES da GeopragDataTable (logo após
os chips de filtro).

Próxima ação: reordenar, testar (existe teste de seleção em massa a
verificar/atualizar), autorevisão/code review, commit.
