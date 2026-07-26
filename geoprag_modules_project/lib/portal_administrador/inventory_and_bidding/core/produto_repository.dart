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
}
