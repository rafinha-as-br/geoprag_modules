import 'insumo.dart';

/// Contrato de acesso aos dados de Insumos (suprimentos) em estoque do
/// aplicador.
///
/// TODO(GEOPRAG-24): contrato real dos endpoints ainda não validado com o
/// backend.
abstract class InsumoRepository {
  Future<List<Insumo>> listar();
}
