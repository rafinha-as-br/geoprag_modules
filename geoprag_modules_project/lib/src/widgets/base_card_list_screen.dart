import 'package:flutter/material.dart';

/// Tudo que uma tela do arquétipo "lista simples/cards" exibe: estado de
/// carregamento/erro, itens, como renderizar cada item e o que mostrar quando
/// não há nenhum.
///
/// O arquétipo (`BlocBuilder` com switch Loading/Error/Loaded → `ListView`/
/// `ListView.separated`) é repetido hoje em `dashboard_distribuicoes`,
/// `solicitacoes_promocao`, `mapa_de_bairros`, `lista_de_insumos`,
/// `recebimentos`, `dashboard_de_focos` e `visualizacao_do_ponto`, com 3
/// tratamentos de lista vazia diferentes entre elas.
///
/// O model é montado pela tela dentro do `BlocBuilder` que ela já tem: o
/// `Cubit` de cada feature continua sendo o controller, e não passa a conviver
/// com uma segunda cópia do mesmo estado. Diferente de `BaseListScreen`
/// (GEOPRAG-83), este arquétipo não ganha um Cubit-base próprio porque as 7
/// telas já têm hierarquias de estado distintas e em produção — uniformizá-las
/// é uma mudança maior, e separada desta.
class BaseCardListScreenModel<T> {
  final bool isLoading;

  /// Mensagem de erro já formatada pela tela, ou `null` se não houve erro.
  final String? errorMessage;

  final List<T> items;

  final Widget Function(BuildContext context, T item) itemBuilder;

  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Texto único de lista vazia — substitui os 3 tratamentos distintos que as
  /// telas de origem tinham.
  final String emptyStateMessage;

  final EdgeInsetsGeometry? padding;

  BaseCardListScreenModel({
    required this.itemBuilder,
    List<T>? items,
    this.isLoading = false,
    this.errorMessage,
    this.separatorBuilder,
    this.emptyStateMessage = 'Nenhum item encontrado.',
    this.padding,
  }) : items = List.unmodifiable(items ?? const []);
}

/// Template de corpo de tela para o arquétipo "lista simples/cards",
/// renderizado inteiramente a partir de um [BaseCardListScreenModel].
///
/// Não inclui `BottomNavigationBar` — isso é o `AplicadorBottomNav`
/// (GEOPRAG-80), composto separadamente pela tela quando aplicável.
class BaseCardListScreen<T> extends StatelessWidget {
  final BaseCardListScreenModel<T> model;

  const BaseCardListScreen({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (model.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(model.errorMessage!),
        ),
      );
    }

    if (model.items.isEmpty) {
      return Center(
        child: Text(
          model.emptyStateMessage,
          style: const TextStyle(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      padding: model.padding,
      itemCount: model.items.length,
      separatorBuilder:
          model.separatorBuilder ?? (context, index) => const Divider(),
      itemBuilder: (context, index) =>
          model.itemBuilder(context, model.items[index]),
    );
  }
}
