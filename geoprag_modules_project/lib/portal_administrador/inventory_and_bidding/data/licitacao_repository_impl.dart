import '../core/licitacao.dart';
import '../core/licitacao_repository.dart';
import 'mock_licitacoes.dart';

/// Implementação de [LicitacaoRepository] com fonte remota mockada
/// (`mockLicitacoes`).
///
/// TODO(GEOPRAG-24): substituir por implementação HTTP real assim que o
/// contrato de endpoints deste módulo for validado com o backend.
class LicitacaoRepositoryImpl implements LicitacaoRepository {
  @override
  Future<List<Licitacao>> listar() async => mockLicitacoes;

  @override
  Future<Licitacao> criar({
    required String numeroAno,
    required String fornecedorVencedor,
    required String objetoLicitado,
    required double valorTotal,
    required DateTime dataHomologacao,
  }) async {
    final licitacao = Licitacao(
      id: 'l${mockLicitacoes.length + 1}',
      numeroAno: numeroAno,
      fornecedorVencedor: fornecedorVencedor,
      objetoLicitado: objetoLicitado,
      valorTotal: valorTotal,
      dataHomologacao: dataHomologacao,
    );
    mockLicitacoes.add(licitacao);
    return licitacao;
  }
}
