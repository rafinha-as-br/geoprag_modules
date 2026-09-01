Estado: EM_EXECUÇÃO

Issue: GEOPRAG-127 — Ocultar CPF por padrão na visualização de aplicadores e
administradores
Repo: geoprag_modules
Branch: feat/GEOPRAG-127-claude (nova, a partir de develop)

Pontos de exibição de CPF encontrados:
- lib/portal_administrador/gerenciamento_de_aplicadores/presentation/visualizacao_individual_screen.dart
  (ListTile subtitle: Text(aplicador.cpf))
- lib/portal_administrador/gerenciamento_de_administradores/presentation/administrador_detalhe_dialog.dart
  (GeopragInfoRow(label: 'CPF', valor: administrador.cpf))

Plano: criar componente reutilizável GeopragMaskedText
(lib/src/widgets/geoprag_masked_text.dart) — StatefulWidget de estado
efêmero (show/hide local), mostra só início/fim por padrão + botão de
alternar (mesmo padrão de exibição de senha). Usar nos dois pontos acima.
GeopragInfoRow precisa de um parâmetro opcional para aceitar um Widget de
valor customizado (hoje só aceita String).

Próxima ação: implementar o widget, integrar nos dois pontos, testes,
autorevisão/code review, commit.
