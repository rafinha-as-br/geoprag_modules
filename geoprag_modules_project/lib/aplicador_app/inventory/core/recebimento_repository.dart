import 'recebimento.dart';

/// Contrato de acesso aos dados de Recebimentos (entregas de insumos) do
/// aplicador.
///
/// TODO(GEOPRAG-24): contrato real dos endpoints ainda não validado com o
/// backend.
abstract class RecebimentoRepository {
  Future<List<Recebimento>> listarPendentes();
  Future<Recebimento> buscarPorId(String id);
  Future<void> confirmar(String id);
}
