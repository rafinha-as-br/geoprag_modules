import '../../../src/entities/aplicacao.dart';
import '../core/aplicacao_repository.dart';
import 'mock_aplicacoes.dart';

/// Implementação de [AplicacaoRepository] com fonte remota mockada
/// (`mockApplications`).
///
/// TODO(GEOPRAG-24): substituir por implementação HTTP real assim que o
/// contrato de endpoints deste módulo for validado com o backend.
class AplicacaoRepositoryImpl implements AplicacaoRepository {
  @override
  Future<Aplicacao> buscarAtual(String aplicadorId) async {
    return mockApplications.firstWhere(
      (aplicacao) => aplicacao.aplicadorId == aplicadorId,
      orElse: () => throw StateError(
        'Nenhuma aplicação em andamento para o aplicador "$aplicadorId".',
      ),
    );
  }
}
