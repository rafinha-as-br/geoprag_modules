import '../core/denuncia.dart';
import '../core/denuncia_repository.dart';
import '../core/historico_denuncia.dart';
import 'mock_denuncias.dart';
import 'mock_historico_denuncias.dart';
import '../../../src/errors/app_exceptions.dart';

/// Implementação de [DenunciaRepository] com fonte remota mockada
/// (`mockReports`/`mockHistoricoDenuncias`).
///
/// TODO(GEOPRAG-24): substituir por implementação HTTP real assim que o
/// contrato de endpoints deste módulo for validado com o backend.
class DenunciaRepositoryImpl implements DenunciaRepository {
  @override
  Future<List<Denuncia>> listar() async => mockReports;

  @override
  Future<Denuncia> buscarPorId(String id) async {
    return mockReports.firstWhere(
      (denuncia) => denuncia.id == id,
      orElse: () => throw EntidadeNaoEncontradaException(
        'Denúncia "$id" não encontrada.',
      ),
    );
  }

  @override
  Future<List<HistoricoDenuncia>> buscarHistorico(String denunciaId) async {
    return mockHistoricoDenuncias[denunciaId] ?? const [];
  }
}
