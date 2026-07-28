import '../core/distribuicao.dart';
import '../core/distribuicao_repository.dart';
import '../core/produto_referencia_distribuicao.dart';
import '../core/responsavel_referencia_distribuicao.dart';
import 'mock_distribuicoes.dart';
import 'mock_produtos_referencia_distribuicao.dart';
import 'mock_responsaveis_referencia_distribuicao.dart';
import '../../../src/errors/app_exceptions.dart';

/// Implementação de [DistribuicaoRepository] com fonte remota mockada
/// (`mockDistribuicoes`/`mockNomesProdutosDistribuicao`/
/// `mockResponsaveisReferenciaDistribuicao`).
///
/// TODO(GEOPRAG-24): substituir por implementação HTTP real assim que o
/// contrato de endpoints deste módulo for validado com o backend.
class DistribuicaoRepositoryImpl implements DistribuicaoRepository {
  @override
  Future<List<Distribuicao>> listar() async => mockDistribuicoes;

  @override
  Future<Distribuicao> buscarPorId(String id) async {
    return mockDistribuicoes.firstWhere(
      (distribuicao) => distribuicao.id == id,
      orElse: () => throw EntidadeNaoEncontradaException('Distribuição "$id" não encontrada.'),
    );
  }

  @override
  Future<String> buscarNomeProduto(String produtoId) async {
    return mockNomesProdutosDistribuicao[produtoId] ??
        'Produto não identificado';
  }

  @override
  Future<List<ProdutoReferenciaDistribuicao>>
  listarProdutosDisponiveis() async {
    return mockProdutosReferenciaDistribuicao;
  }

  @override
  Future<List<ResponsavelReferenciaDistribuicao>>
  listarResponsaveisDisponiveis() async {
    return mockResponsaveisReferenciaDistribuicao;
  }
}
