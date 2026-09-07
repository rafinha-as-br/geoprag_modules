Estado: EM_EXECUÇÃO
Issue: GEOPRAG-112 — Esquema de permissões por capacidade (Portal Administrador)
Repositório: geoprag_modules
Branch: feat/GEOPRAG-112-claude (nova, criada a partir de develop)

Objetivo: enum de capacidades do sistema + mapa cargo→capacidades (paridade
total hoje) + consulta `podeExecutar`/`garantirCapacidade` no
AdminSessionCubit + widget `GatedActionButton` + tela `AcessoNegadoScreen`.
Escopo explícito: só Portal Administrador, sem retrofit de telas existentes
(isso é swap mecânico de issues futuras, fora daqui).

Concluído até agora:
- lib/src/permissions/capacidade.dart (enum Capacidade, sem imports)
- lib/portal_administrador/autenticacao/core/capacidades_por_cargo.dart
  (mapa AdminRole -> Set<Capacidade>; movido de lib/src/ para core/ na
  autorevisão 5.3b, para não violar "camadas não voltam" — o mapa depende
  de AdminRole, que é do domínio de autenticacao)
- admin_session_cubit.dart: métodos podeExecutar() e garantirCapacidade()
- lib/portal_administrador/widgets/gated_action_button.dart
- lib/portal_administrador/widgets/acesso_negado_screen.dart
- barrel geoprag_modules.dart: export de capacidade.dart
- Testes: admin_session_cubit_test.dart (podeExecutar/garantirCapacidade),
  capacidades_por_cargo_test.dart (em test/portal_administrador/autenticacao/core/),
  gated_action_button_test.dart, acesso_negado_screen_test.dart
- Autorevisão flutter-development-standards (5.3b): concluída, 1 violação
  encontrada e corrigida (seção 1, ver acima). Demais seções sem violações.

Code review automatizado (5.3c): /code-review medium e ponytail-review, ambos
sem achados.

Gate de qualidade (5.4): flutter analyze limpo para os arquivos novos (12
issues pré-existentes, nenhum relacionado); flutter test completo (734
testes) passando. Corrigido durante o gate: teste de AcessoNegadoScreen
faltava prover AdminSessionCubit (AdminScaffold/SidebarMenu exige); testes de
GatedActionButton usavam find.byType(OutlinedButton), que não casa com a
subclasse privada retornada por OutlinedButton.icon — trocado por
byWidgetPredicate.

Próxima ação: commit + push + abrir PR (5.5/5.6).
