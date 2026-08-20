import 'package:flutter/material.dart';

/// As duas variantes hoje coexistentes de tela de detalhe, sem critério
/// documentado de quando usar cada uma antes do [BaseDetailScreen]:
/// [duasColunas] (página cheia, ex.: `visualizacao_individual_screen.dart`)
/// e [cartaoCentralizado] (cartão estreito centralizado, ex.:
/// `visualizacao_produto_screen.dart`).
enum BaseDetailScreenVariant { duasColunas, cartaoCentralizado }

/// Template de corpo de tela para o arquétipo "detalhe", cobrindo as duas
/// variantes visuais hoje reimplementadas independentemente em 7 telas.
/// Compartilha o mesmo switch de estado (loading/erro/conteúdo) e expõe um
/// slot explícito [actions] — em vez de cada tela decidir sozinha se as
/// ações vão no header, no corpo ou no rodapé, o template sempre as coloca
/// à direita do título.
///
/// [duasColunas] não inclui `AdminScaffold` — como os demais templates
/// deste pacote, este é só o corpo; a página (`AdminScaffold`, `AppBar`)
/// continua sendo montada pelo chamador. [cartaoCentralizado] envolve o
/// conteúdo em `Center` + `Container(width: 600)` + `Card(elevation: 4,
/// radius: 16)`, reproduzindo a variante existente.
///
/// [contentBuilder] só é chamado quando [isLoading] é `false` e
/// [errorMessage] é `null`.
class BaseDetailScreen extends StatelessWidget {
  final BaseDetailScreenVariant variant;
  final String title;
  final List<Widget> actions;
  final bool isLoading;
  final String? errorMessage;
  final WidgetBuilder contentBuilder;

  const BaseDetailScreen({
    super.key,
    required this.variant,
    required this.title,
    this.actions = const [],
    required this.isLoading,
    this.errorMessage,
    required this.contentBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final body = _buildBody(context);

    if (variant == BaseDetailScreenVariant.cartaoCentralizado) {
      return Center(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(32.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(padding: const EdgeInsets.all(32.0), child: body),
          ),
        ),
      );
    }

    return body;
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    final titleStyle = TextStyle(
      fontSize: variant == BaseDetailScreenVariant.cartaoCentralizado
          ? 24
          : 28,
      fontWeight: FontWeight.bold,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(title, style: titleStyle)),
            if (actions.isNotEmpty)
              Row(mainAxisSize: MainAxisSize.min, children: actions),
          ],
        ),
        const SizedBox(height: 24),
        contentBuilder(context),
      ],
    );
  }
}
