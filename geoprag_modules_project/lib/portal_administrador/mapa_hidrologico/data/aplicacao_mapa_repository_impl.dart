import '../../../src/entities/aplicacao.dart';
import 'mock_aplicacoes.dart';
import '../core/aplicacao_mapa_repository.dart';
import '../../../src/errors/app_exceptions.dart';

/// Implementação de [AplicacaoMapaRepository] sobre a fonte mockada
/// (`mockApplications`).
///
/// TODO(GEOPRAG-24): substituir por implementação HTTP real assim que o
/// contrato de endpoints deste módulo for validado com o backend.
class AplicacaoMapaRepositoryImpl implements AplicacaoMapaRepository {
  @override
  Future<Aplicacao> buscarPorId(String id) async {
    return mockApplications.firstWhere(
      (aplicacao) => aplicacao.id == id,
      orElse: () => throw EntidadeNaoEncontradaException(
        'Aplicação "$id" não encontrada.',
      ),
    );
  }
}
