import 'denuncia.dart';
import 'historico_denuncia.dart';

/// Contrato de acesso aos dados de Denúncias (focos reportados) do Portal
/// Administrador.
///
/// TODO(GEOPRAG-24): contrato real dos endpoints ainda não validado com o
/// backend.
abstract class DenunciaRepository {
  Future<List<Denuncia>> listar();
  Future<Denuncia> buscarPorId(String id);
  Future<List<HistoricoDenuncia>> buscarHistorico(String denunciaId);
}
