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
/// abaixo do título, alinhadas à direita (empilhadas, não lado a lado —
/// GEOPRAG-109/110).
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

    // Scrollable: o corpo é limitado à altura da viewport (Scaffold/Card),
    // mas o conteúdo varia por tela (listas, históricos, mapa com altura
    // fixa) e pode ultrapassá-la — sem isso, RenderFlex estoura.
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título e ações empilhados (não lado a lado): com título longo e
          // várias ações (GEOPRAG-109/110 somaram 4 botões no mesmo header),
          // um Row com Expanded deixava a coluna do título estreita demais e
          // as ações renderizavam por cima do texto quebrado em várias
          // linhas. Empilhar sempre evita a disputa de espaço horizontal, e
          // o Wrap deixa os próprios botões quebrarem linha entre si quando
          // não cabem lado a lado.
          Text(title, style: titleStyle),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: actions,
            ),
          ],
          if (variant == BaseDetailScreenVariant.cartaoCentralizado)
            const Divider(height: 32)
          else
            const SizedBox(height: 24),
          contentBuilder(context),
        ],
      ),
    );
  }
}
