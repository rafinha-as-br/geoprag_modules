import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../portal_administrador/gerenciamento_de_administradores/presentation/widgets/geoprag_data_table.dart';
import '../state/acao_feedback.dart';
import 'base_screen_feedback.dart';

/// Tudo que uma tela do arquétipo "lista/dashboard tabular administrativo"
/// exibe: título, ações do cabeçalho, barra de filtro, colunas, itens, estado
/// de carregamento/erro, empty-state e feedback pós-ação.
///
/// O arquétipo é repetido hoje quase char-a-char em `dashboard_aplicadores`,
/// `dashboard_administradores`, `dashboard_estoque`,
/// `dashboard_denuncias_admin`, `listagem_de_denuncias` e
/// `formula_de_dosagem`, com apenas 2 das 6 telas tratando lista vazia e
/// duas tabelas concorrentes coexistindo (`GeopragDataTable` genérico vs.
/// `Table`/`TableRow` cru duplicado em 3 telas).
///
/// Este model é o **estado** de [BaseListScreenController] — não uma camada
/// de estado a mais ao lado do `Cubit` da tela, mas o próprio estado dele.
class BaseListScreenModel<T> {
  /// Título 28/bold no topo do corpo da tela.
  final String title;

  /// Botões do cabeçalho, à direita do [title].
  final List<Widget> actions;

  /// Campo de busca/filtro exibido no topo do card. `null` para telas sem
  /// filtro — não existe filtro decorativo neste template: ou a tela informa
  /// um filtro que de fato filtra [items], ou não informa nenhum.
  final Widget? filter;

  /// Colunas da tabela. `GeopragDataTable` é a única forma de tabela do
  /// template — não há slot para `Table`/`TableRow` customizado.
  final List<GeopragDataColumn<T>> columns;

  /// Itens já filtrados, prontos para renderizar.
  final List<T> items;

  final bool isLoading;

  /// Mensagem crua do erro de carregamento, ou `null` se não houve erro.
  final String? errorMessage;

  /// Nome da entidade listada, usado pela frase padrão de [errorText]
  /// (ex.: "os administradores").
  final String entityLabel;

  /// O que exibir quando [items] está vazio. Obrigatório justamente para que
  /// nenhuma tela migrada esqueça de tratar lista vazia.
  final Widget emptyState;

  /// Resultado da última ação do usuário, no contrato único da GEOPRAG-77.
  final AcaoFeedback? feedback;

  /// Ação ao tocar numa linha, ou `null` para linhas não clicáveis.
  final void Function(T item)? onRowTap;

  /// Frase de erro alternativa, para as telas que não usam a convenção do
  /// pacote. É um campo, e não um getter sobrescrevível por subclasse, porque
  /// [copyWith] reconstrói sempre um [BaseListScreenModel] — uma subclasse não
  /// sobreviveria à primeira emissão de estado.
  final String Function(String message)? errorTextBuilder;

  /// A lista nasce carregando: sem isso, uma tela que ainda não emitiu nada
  /// exibiria o empty-state ("nenhum registro") no primeiro frame, dando ao
  /// usuário a informação errada sobre um dado que só está a caminho.
  BaseListScreenModel({
    required this.title,
    required this.entityLabel,
    required this.columns,
    required this.emptyState,
    this.actions = const [],
    this.filter,
    List<T> items = const [],
    this.isLoading = true,
    this.errorMessage,
    this.feedback,
    this.onRowTap,
    this.errorTextBuilder,
  }) : items = List.unmodifiable(items);

  /// Frase de erro exibida ao usuário: por padrão a convenção já usada nas 6
  /// telas de origem, ou o que [errorTextBuilder] definir.
  String get errorText =>
      errorTextBuilder?.call(errorMessage ?? '') ??
      'Não foi possível carregar $entityLabel: $errorMessage';

  BaseListScreenModel<T> copyWith({
    List<Widget>? actions,
    Widget? filter,
    List<T>? items,
    bool? isLoading,
    String? errorMessage,
    AcaoFeedback? feedback,
    bool limparErro = false,
    bool limparFeedback = false,
  }) {
    return BaseListScreenModel<T>(
      title: title,
      entityLabel: entityLabel,
      columns: columns,
      emptyState: emptyState,
      onRowTap: onRowTap,
      errorTextBuilder: errorTextBuilder,
      actions: actions ?? this.actions,
      filter: filter ?? this.filter,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: limparErro ? null : (errorMessage ?? this.errorMessage),
      feedback: limparFeedback ? null : (feedback ?? this.feedback),
    );
  }
}

/// Controller reutilizável do arquétipo de lista tabular administrativa.
///
/// É um `Cubit` cujo estado é o próprio [BaseListScreenModel]: o Cubit que a
/// tela já tem continua sendo o controller dela, e não passa a conviver com
/// uma segunda cópia do mesmo estado. Cada tela estende este controller,
/// informa no `super` o que é fixo (título, colunas, empty-state, rótulo da
/// entidade) e conduz o carregamento por [emitLoading], [emitItems],
/// [emitError] e [emitFeedback].
abstract class BaseListScreenController<T>
    extends Cubit<BaseListScreenModel<T>> {
  BaseListScreenController(super.initialState);

  void emitLoading() {
    emit(
      state.copyWith(isLoading: true, limparErro: true, limparFeedback: true),
    );
  }

  void emitItems(List<T> items) {
    emit(state.copyWith(items: items, isLoading: false, limparErro: true));
  }

  void emitError(String message) {
    emit(state.copyWith(errorMessage: message, isLoading: false));
  }

  void emitFeedback(AcaoFeedback? feedback) {
    emit(
      feedback == null
          ? state.copyWith(limparFeedback: true)
          : state.copyWith(feedback: feedback),
    );
  }
}

/// Template de corpo de tela para o arquétipo "lista/dashboard tabular
/// administrativo", renderizado inteiramente a partir do estado de um
/// [BaseListScreenController] fornecido acima na árvore.
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
class BaseListScreen<C extends BaseListScreenController<T>, T>
    extends StatelessWidget {
  const BaseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, BaseListScreenModel<T>>(
      builder: (context, model) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    model.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(mainAxisSize: MainAxisSize.min, children: model.actions),
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
                    if (model.filter != null) ...[
                      model.filter!,
                      const SizedBox(height: 16),
                    ],
                    if (model.feedback != null) ...[
                      BaseScreenFeedback(feedback: model.feedback!),
                      const SizedBox(height: 16),
                    ],
                    _buildContent(model),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BaseListScreenModel<T> model) {
    if (model.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (model.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(model.errorText),
      );
    }

    if (model.items.isEmpty) {
      return model.emptyState;
    }

    return GeopragDataTable<T>(
      items: model.items,
      columns: model.columns,
      onRowTap: model.onRowTap,
    );
  }
}
