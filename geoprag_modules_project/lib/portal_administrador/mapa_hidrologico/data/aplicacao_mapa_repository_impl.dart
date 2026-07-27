import '../../../src/entities/aplicacao.dart';
import '../../../aplicador_app/applications/data/mock_aplicacoes.dart';
import '../core/aplicacao_mapa_repository.dart';

/// Implementação de [AplicacaoMapaRepository] reaproveitando a fonte mockada
/// já existente do módulo `aplicador_app/applications`
/// (`mockApplications`), em vez de duplicar os mesmos dados aqui.
///
/// TODO(GEOPRAG-24): substituir por implementação HTTP real assim que o
/// contrato de endpoints deste módulo for validado com o backend.
class AplicacaoMapaRepositoryImpl implements AplicacaoMapaRepository {
  @override
  Future<Aplicacao> buscarPorId(String id) async {
    return mockApplications.firstWhere(
      (aplicacao) => aplicacao.id == id,
      orElse: () => throw StateError('Aplicação "$id" não encontrada.'),
    );
  }
}
