import '../core/insumo.dart';
import '../core/insumo_repository.dart';
import 'mock_insumos.dart';

/// Implementação de [InsumoRepository] com fonte remota mockada
/// (`mockInsumos`).
///
/// TODO(GEOPRAG-24): substituir por implementação HTTP real assim que o
/// contrato de endpoints deste módulo for validado com o backend.
class InsumoRepositoryImpl implements InsumoRepository {
  @override
  Future<List<Insumo>> listar() async => mockInsumos;
}
