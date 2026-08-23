import 'distribuicao.dart';
import 'produto_referencia_distribuicao.dart';
import 'responsavel_referencia_distribuicao.dart';

/// Contrato de acesso aos dados de Distribuições (saídas de produto) do
/// Portal Administrador.
///
/// TODO(GEOPRAG-24): contrato real dos endpoints ainda não validado com o
/// backend.
abstract class DistribuicaoRepository {
  Future<List<Distribuicao>> listar();
  Future<Distribuicao> buscarPorId(String id);

  /// Resolve o nome de exibição de um produto (ex.: `'BTI Líquido - Lote
  /// L-001'`) a partir do seu `produtoId`.
  ///
  /// TODO(GEOPRAG-24): hoje resolvido localmente porque não há dependência
  /// real ao módulo `inventory_and_bidding`; ver
  /// `core/produto_referencia_distribuicao.dart`.
  Future<String> buscarNomeProduto(String produtoId);

  /// Produtos disponíveis para seleção no formulário de nova distribuição.
  Future<List<ProdutoReferenciaDistribuicao>> listarProdutosDisponiveis();

  /// Responsáveis de campo disponíveis para seleção no formulário de nova
  /// distribuição.
  Future<List<ResponsavelReferenciaDistribuicao>>
  listarResponsaveisDisponiveis();
}
