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

  @override
  Future<Produto> registrarEntrada({
    required String nome,
    required String lote,
    required DateTime dataValidade,
    required int quantidade,
    required String unidadeMedida,
    required String licitacao,
    required String fornecedor,
  }) async {
    final produto = Produto(
      id: 'p${mockProdutos.length + 1}',
      nome: nome,
      lote: lote,
      dataValidade: dataValidade,
      status: 'Produto em estoque',
      quantidade: quantidade,
      quantidadeOriginal: quantidade,
      unidadeMedida: unidadeMedida,
      licitacao: licitacao,
      fornecedor: fornecedor,
    );
    mockProdutos.add(produto);
    return produto;
  }

  @override
  Future<FormulaDosagem> criarFormula({
    required String produtoId,
    required double fatorConversao,
    required double distanciaCarreamento,
    required double fatorCorrecao,
  }) async {
    final produto = await buscarPorId(produtoId);
    // Um produto tem no máximo uma fórmula — repetir o cadastro para o
    // mesmo produto atualiza a fórmula existente em vez de duplicar a
    // linha (o botão "Editar" da listagem ainda não abre esta tela
    // preenchida, então isso é hoje o único jeito de corrigir uma fórmula).
    final existente = mockFormulasDosagem.indexWhere(
      (f) => f.produtoId == produtoId,
    );
    final formula = FormulaDosagem(
      id: existente == -1
          ? 'f${mockFormulasDosagem.length + 1}'
          : mockFormulasDosagem[existente].id,
      produtoId: produtoId,
      produtoNome: produto.nome,
      fatorConversao: fatorConversao,
      distanciaCarreamento: distanciaCarreamento,
      fatorCorrecao: fatorCorrecao,
      atualizadoEm: DateTime.now(),
    );
    if (existente == -1) {
      mockFormulasDosagem.add(formula);
    } else {
      mockFormulasDosagem[existente] = formula;
    }
    return formula;
  }
}
