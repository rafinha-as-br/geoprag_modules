enum MovimentacaoProdutoTipo { entrada, saida }

/// Um item do histórico de movimentações de estoque de um [Produto] (entrada
/// de compra/recebimento ou saída para distribuição) exibido na tela de
/// detalhe.
class MovimentacaoProduto {
  final MovimentacaoProdutoTipo tipo;
  final String titulo;
  final String subtitulo;
  final String valor;

  const MovimentacaoProduto({
    required this.tipo,
    required this.titulo,
    required this.subtitulo,
    required this.valor,
  });
}
