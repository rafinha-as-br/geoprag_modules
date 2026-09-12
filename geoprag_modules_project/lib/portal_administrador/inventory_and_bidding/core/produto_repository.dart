import 'formula_dosagem.dart';
import 'movimentacao_produto.dart';
import 'produto.dart';

/// Contrato de acesso aos dados de Produtos (itens de estoque de BTI) do
/// Portal Administrador.
///
/// TODO(GEOPRAG-24): contrato real dos endpoints ainda não validado com o
/// backend.
abstract class ProdutoRepository {
  Future<List<Produto>> listar();
  Future<Produto> buscarPorId(String id);
  Future<List<MovimentacaoProduto>> buscarMovimentacoes(String produtoId);
  Future<List<FormulaDosagem>> listarFormulas();

  /// Registra uma nova entrada de produto/lote no estoque — nasce sempre
  /// `Produto em estoque`, com `quantidadeOriginal` igual à quantidade
  /// recebida.
  Future<Produto> registrarEntrada({
    required String nome,
    required String lote,
    required DateTime dataValidade,
    required int quantidade,
    required String unidadeMedida,
    required String licitacao,
    required String fornecedor,
  });

  /// Cria ou atualiza a fórmula de dosagem de BTI vinculada a um produto do
  /// fabricante.
  Future<FormulaDosagem> criarFormula({
    required String produtoId,
    required double fatorConversao,
    required double distanciaCarreamento,
    required double fatorCorrecao,
  });
}
