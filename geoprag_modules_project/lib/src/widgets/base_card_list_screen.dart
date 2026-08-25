import 'package:flutter/material.dart';

/// Template de corpo de tela para o arquétipo "lista simples/cards"
/// (`BlocBuilder` com switch Loading/Error/Loaded → `ListView`/
/// `ListView.separated`), repetido hoje em `dashboard_distribuicoes`,
/// `solicitacoes_promocao`, `mapa_de_bairros`, `lista_de_insumos`,
/// `recebimentos`, `dashboard_de_focos` e `visualizacao_do_ponto`.
///
/// O chamador continua responsável por resolver o próprio `Cubit`/`State`
/// (cada feature tem uma hierarquia de estado diferente) e repassar o
/// resultado já mapeado via [isLoading]/[errorMessage]/[items] — o template
/// só decide o que renderizar a partir desse resultado, incluindo o
/// empty-state único (hoje há 5 implementações diferentes no pacote).
///
/// Não inclui `BottomNavigationBar` — isso é o `AplicadorBottomNav`
/// (GEOPRAG-80), composto separadamente pelo chamador quando aplicável.
///
/// GEOPRAG-83 (`BaseListScreen`, arquétipo de lista tabular administrativa)
/// ainda não existe neste pacote — a convenção de erro usada aqui
/// (`Center` + `Text` com a mensagem já formatada pelo chamador) foi
/// definida localmente e deve ser revisada/alinhada quando GEOPRAG-83 for
/// implementada, para as duas convenções não divergirem.
class BaseCardListScreen<T> extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<T>? items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final String emptyStateMessage;
  final EdgeInsetsGeometry? padding;

  const BaseCardListScreen({
    super.key,
    required this.isLoading,
    required this.items,
    required this.itemBuilder,
    this.errorMessage,
    this.separatorBuilder,
    this.emptyStateMessage = 'Nenhum item encontrado.',
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(errorMessage!),
        ),
      );
    }

    final resolvedItems = items ?? const [];
    if (resolvedItems.isEmpty) {
      return Center(
        child: Text(
          emptyStateMessage,
          style: const TextStyle(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      padding: padding,
      itemCount: resolvedItems.length,
      separatorBuilder: separatorBuilder ?? (context, index) => const Divider(),
      itemBuilder: (context, index) => itemBuilder(context, resolvedItems[index]),
    );
  }
}
