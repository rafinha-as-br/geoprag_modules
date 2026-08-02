import '../core/formula_dosagem.dart';
import '../core/movimentacao_produto.dart';
import '../core/produto.dart';
import '../core/produto_repository.dart';
import 'mock_formulas_dosagem.dart';
import 'mock_movimentacoes_produto.dart';
import 'mock_produtos.dart';
import '../../../src/errors/app_exceptions.dart';

/// Implementação de [ProdutoRepository] com fonte remota mockada
/// (`mockProdutos`/`mockMovimentacoesProduto`/`mockFormulasDosagem`).
///
/// TODO(GEOPRAG-24): substituir por implementação HTTP real assim que o
/// contrato de endpoints deste módulo for validado com o backend.
class ProdutoRepositoryImpl implements ProdutoRepository {
  @override
  Future<List<Produto>> listar() async => mockProdutos;

  @override
  Future<Produto> buscarPorId(String id) async {
    return mockProdutos.firstWhere(
      (produto) => produto.id == id,
      orElse: () =>
          throw EntidadeNaoEncontradaException('Produto "$id" não encontrado.'),
    );
  }

  @override
  Future<List<MovimentacaoProduto>> buscarMovimentacoes(
    String produtoId,
  ) async {
    return mockMovimentacoesProduto[produtoId] ?? const [];
  }

  @override
  Future<List<FormulaDosagem>> listarFormulas() async => mockFormulasDosagem;
}
