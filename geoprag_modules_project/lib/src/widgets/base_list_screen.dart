import 'package:flutter/material.dart';

import '../../portal_administrador/gerenciamento_de_administradores/presentation/widgets/geoprag_data_table.dart';
import '../state/acao_feedback.dart';
import 'base_screen_feedback.dart';

/// Contrato de tudo que uma tela do arquétipo "lista/dashboard tabular
/// administrativo" exibe: título, ações do cabeçalho, barra de filtro,
/// colunas, itens, estado de carregamento/erro, empty-state e feedback
/// pós-ação.
///
/// O arquétipo é repetido hoje quase char-a-char em `dashboard_aplicadores`,
/// `dashboard_administradores`, `dashboard_estoque`,
/// `dashboard_denuncias_admin`, `listagem_de_denuncias` e
/// `formula_de_dosagem`, com apenas 2 das 6 telas tratando lista vazia e
/// duas tabelas concorrentes coexistindo (`GeopragDataTable` genérico vs.
/// `Table`/`TableRow` cru duplicado em 3 telas).
///
/// Quem implementa este contrato na prática é [BaseListScreenController] —
/// cada tela estende o controller e declara aqui o que é específico dela.
abstract class BaseListScreenModel<T> {
  /// Título 28/bold no topo do corpo da tela.
  String get title;

  /// Botões do cabeçalho, à direita do [title].
  List<Widget> get actions;

  /// Campo de busca/filtro exibido no topo do card. `null` para telas sem
  /// filtro — não existe filtro decorativo neste template: ou a tela informa
  /// um filtro que de fato filtra [items], ou não informa nenhum.
  Widget? get filter;

  /// Colunas da tabela. `GeopragDataTable` é a única forma de tabela do
  /// template — não há slot para `Table`/`TableRow` customizado.
  List<GeopragDataColumn<T>> get columns;

  /// Itens já filtrados, prontos para renderizar.
  List<T> get items;

  bool get isLoading;

  /// Mensagem crua do erro de carregamento, ou `null` se não houve erro.
  String? get errorMessage;

  /// Nome da entidade listada, usado pela frase padrão de [errorText]
  /// (ex.: "os administradores").
  String get entityLabel;

  /// O que exibir quando [items] está vazio. Obrigatório justamente para que
  /// nenhuma tela migrada esqueça de tratar lista vazia.
  Widget get emptyState;

  /// Resultado da última ação do usuário, no contrato único da GEOPRAG-77.
  AcaoFeedback? get feedback;

  /// Ação ao tocar numa linha, ou `null` para linhas não clicáveis.
  void Function(T item)? get onRowTap;

  /// Frase de erro exibida ao usuário. O default é a convenção já usada nas
  /// 6 telas de origem; sobrescreva apenas nas telas que precisem de outra.
  String errorText(String message) =>
      'Não foi possível carregar $entityLabel: $message';
}

/// Controller reutilizável do arquétipo de lista tabular administrativa:
/// estende [BaseListScreenModel] e passa a notificar a tela a cada mudança,
/// de modo que [BaseListScreen] possa ser um `StatelessWidget`.
///
/// A tela concreta estende este controller, declara o que é específico dela
/// ([title], [columns], [emptyState], [entityLabel] e o que mais quiser
/// sobrescrever) e dirige o ciclo de carregamento por [setLoading],
/// [setItems], [setError] e [setFeedback].
///
/// O controller é um `ChangeNotifier`: quem o cria é responsável por chamá-lo
/// em `dispose()` — [BaseListScreen] apenas o consome, nunca assume sua posse.
abstract class BaseListScreenController<T> extends BaseListScreenModel<T>
    with ChangeNotifier {
  List<T> _items = const [];

  /// A lista nasce carregando: sem isso, uma tela que ainda não chamou
  /// [setLoading] exibiria o empty-state ("nenhum registro") no primeiro
  /// frame, dando ao usuário a informação errada sobre um dado que só está
  /// a caminho.
  bool _isLoading = true;

  String? _errorMessage;
  AcaoFeedback? _feedback;

  @override
  List<T> get items => _items;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;

  @override
  AcaoFeedback? get feedback => _feedback;

  @override
  List<Widget> get actions => const [];

  @override
  Widget? get filter => null;

  @override
  void Function(T item)? get onRowTap => null;

  void setLoading() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void setItems(List<T> items) {
    _items = List.unmodifiable(items);
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void setFeedback(AcaoFeedback? feedback) {
    _feedback = feedback;
    notifyListeners();
  }
}

/// Template de corpo de tela para o arquétipo "lista/dashboard tabular
/// administrativo", renderizado inteiramente a partir de um
/// [BaseListScreenController].
///
/// Como os demais templates do pacote (`BaseCardListScreen`,
/// `BaseDetailScreen`, `BaseInterstitialScreen`), cobre só o corpo da tela:
/// `AdminScaffold`, `AppBar` e rota atual ficam com a tela que compõe este
/// template, não aqui dentro.
///
/// Este arquivo vive em `lib/src/` mas importa `GeopragDataTable` de
/// `lib/portal_administrador/` — um import que sobe de camada, herdado do
/// lugar onde a tabela genérica nasceu (módulo de Administradores). Mover a
/// tabela para `lib/src/widgets/` resolveria, mas atinge consumidores fora do
/// escopo deste template.
class BaseListScreen<T> extends StatelessWidget {
  final BaseListScreenController<T> controller;

  const BaseListScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    controller.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: controller.actions,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (controller.filter != null) ...[
                      controller.filter!,
                      const SizedBox(height: 16),
                    ],
                    if (controller.feedback != null) ...[
                      BaseScreenFeedback(feedback: controller.feedback!),
                      const SizedBox(height: 16),
                    ],
                    _buildContent(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final errorMessage = controller.errorMessage;
    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(controller.errorText(errorMessage)),
      );
    }

    if (controller.items.isEmpty) {
      return controller.emptyState;
    }

    return GeopragDataTable<T>(
      items: controller.items,
      columns: controller.columns,
      onRowTap: controller.onRowTap,
    );
  }
}
