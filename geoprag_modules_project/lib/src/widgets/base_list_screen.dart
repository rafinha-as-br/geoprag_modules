import 'package:flutter/material.dart';

import '../../portal_administrador/gerenciamento_de_administradores/presentation/widgets/geoprag_data_table.dart';
import '../../portal_administrador/widgets/admin_scaffold.dart';
import '../state/acao_feedback.dart';
import '../theme/geoprag_colors.dart';

/// Template de tela para o arquétipo "lista/dashboard tabular
/// administrativo", repetido hoje quase char-a-char em
/// `dashboard_aplicadores`, `dashboard_administradores`, `dashboard_estoque`,
/// `dashboard_denuncias_admin`, `listagem_de_denuncias` e
/// `formula_de_dosagem`: `AdminScaffold` + título 28/bold + `Card(elevation:
/// 3, radius: 12)` envolvendo um card de filtro + switch
/// Loading/Error/Loaded, hoje com apenas 2 das 6 telas tratando lista vazia
/// e duas tabelas concorrentes coexistindo (`GeopragDataTable` genérico vs.
/// `Table`/`TableRow` cru duplicado em 3 telas).
///
/// Diferente dos demais templates deste pacote (`BaseCardListScreen`,
/// `BaseDetailScreen`, `BaseInterstitialScreen`, que só cobrem o corpo da
/// tela), este monta o `AdminScaffold` inteiro — decisão explícita da
/// GEOPRAG-83, já que as 6 telas de origem são exclusivas do Portal
/// Administrador (web) e sempre o envolvem. Por isso este arquivo, embora
/// viva em `lib/src/widgets/`, importa `AdminScaffold` e `GeopragDataTable`
/// de dentro de `lib/portal_administrador/` — uma exceção deliberada à
/// separação usual entre `src` (compartilhado) e `portal_administrador`
/// (específico de plataforma).
///
/// `GeopragDataTable` é a única forma de tabela suportada pelo template —
/// não há slot para um `Table`/`TableRow` customizado. O empty-state
/// ([emptyStateBuilder]) é obrigatório (não tem default), para que nenhuma
/// tela migrada esqueça de tratar lista vazia. A mensagem de erro segue por
/// padrão a convenção "Não foi possível carregar $entityLabel: $message" já
/// usada nas 6 telas, sobrescrevível via [errorMessageBuilder] para os casos
/// que precisem de outra frase. O feedback pós-ação ([feedback]) segue o
/// contrato único decidido na GEOPRAG-77 ([AcaoFeedback]), exibido como
/// `SnackBar` colorido conforme [AcaoFeedbackSucesso]/[AcaoFeedbackErro] sem
/// inspecionar a mensagem.
///
/// Esta issue (GEOPRAG-83) só cria o template — a migração das 6 telas é
/// escopo da GEOPRAG-90.
class BaseListScreen<T> extends StatefulWidget {
  final String currentRoute;
  final String appBarTitle;
  final String title;
  final List<Widget> actions;
  final Widget filterBar;
  final bool isLoading;
  final String? errorMessage;
  final String entityLabel;
  final String Function(String message)? errorMessageBuilder;
  final List<T>? items;
  final List<GeopragDataColumn<T>> columns;
  final void Function(T item)? onRowTap;
  final WidgetBuilder emptyStateBuilder;
  final AcaoFeedback? feedback;

  const BaseListScreen({
    super.key,
    required this.currentRoute,
    required this.appBarTitle,
    required this.title,
    this.actions = const [],
    required this.filterBar,
    required this.isLoading,
    this.errorMessage,
    required this.entityLabel,
    this.errorMessageBuilder,
    required this.items,
    required this.columns,
    this.onRowTap,
    required this.emptyStateBuilder,
    this.feedback,
  });

  @override
  State<BaseListScreen<T>> createState() => _BaseListScreenState<T>();
}

class _BaseListScreenState<T> extends State<BaseListScreen<T>> {
  @override
  void didUpdateWidget(covariant BaseListScreen<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final feedback = widget.feedback;
    // Comparação por identidade, não por valor: `AcaoFeedback` sobrescreve
    // `==` por (runtimeType, mensagem), então duas ações distintas com a
    // mesma mensagem genérica (ex.: "Aplicador ativado com sucesso." em dois
    // registros diferentes) seriam consideradas o mesmo feedback e a segunda
    // SnackBar nunca apareceria.
    if (feedback != null && !identical(feedback, oldWidget.feedback)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _mostrarFeedback(feedback);
      });
    }
  }

  void _mostrarFeedback(AcaoFeedback feedback) {
    final cor = switch (feedback) {
      AcaoFeedbackSucesso() => GeopragColors.statusEmDia,
      AcaoFeedbackErro() => GeopragColors.statusAtrasado,
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(feedback.mensagem), backgroundColor: cor));
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: widget.currentRoute,
      appBar: AppBar(title: Text(widget.appBarTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                if (widget.actions.isNotEmpty)
                  Row(mainAxisSize: MainAxisSize.min, children: widget.actions),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    widget.filterBar,
                    const SizedBox(height: 16),
                    _buildEstado(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstado(BuildContext context) {
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final errorMessage = widget.errorMessage;
    if (errorMessage != null) {
      final texto = widget.errorMessageBuilder != null
          ? widget.errorMessageBuilder!(errorMessage)
          : 'Não foi possível carregar ${widget.entityLabel}: $errorMessage';
      return Padding(padding: const EdgeInsets.all(24), child: Text(texto));
    }

    final items = widget.items ?? const [];
    if (items.isEmpty) {
      return widget.emptyStateBuilder(context);
    }

    return GeopragDataTable<T>(
      items: items,
      columns: widget.columns,
      onRowTap: widget.onRowTap,
    );
  }
}
