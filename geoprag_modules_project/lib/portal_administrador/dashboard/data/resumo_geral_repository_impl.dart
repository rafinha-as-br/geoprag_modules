import '../core/resumo_geral.dart';
import '../core/resumo_geral_repository.dart';
import 'mock_resumo_geral.dart';

/// Implementação de [ResumoGeralRepository] com fonte remota mockada
/// (`mockResumoGeral`).
///
/// TODO(GEOPRAG-24): substituir por implementação HTTP real assim que o
/// contrato de endpoints deste módulo for validado com o backend.
class ResumoGeralRepositoryImpl implements ResumoGeralRepository {
  @override
  Future<ResumoGeral> buscar() async => mockResumoGeral;
}
