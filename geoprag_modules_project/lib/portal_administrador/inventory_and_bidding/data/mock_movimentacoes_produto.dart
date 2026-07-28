import '../core/movimentacao_produto.dart';

/// Histórico de movimentações por `produtoId`, usado para simular a tela de
/// detalhe enquanto não há agregação real com o módulo de distribuições.
final Map<String, List<MovimentacaoProduto>> mockMovimentacoesProduto = {
  'p1': const [
    MovimentacaoProduto(
      tipo: MovimentacaoProdutoTipo.saida,
      titulo: 'Saída para Belchior Alto',
      subtitulo: 'Resp: João Silva - 05/07/2026',
      valor: '10 Litros',
    ),
    MovimentacaoProduto(
      tipo: MovimentacaoProdutoTipo.saida,
      titulo: 'Saída para Gasparinho',
      subtitulo: 'Resp: Maria Souza - 20/06/2026',
      valor: '5 Litros',
    ),
  ],
  'p4': const [
    MovimentacaoProduto(
      tipo: MovimentacaoProdutoTipo.entrada,
      titulo: 'Entrada por Compra',
      subtitulo: 'Pregão 02/2026 - 01/06/2026',
      valor: '100 Kg recebidos',
    ),
  ],
};
