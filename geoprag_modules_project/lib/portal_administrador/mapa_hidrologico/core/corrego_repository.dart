import 'bairro.dart';
import 'corrego.dart';

/// Contrato de acesso aos dados de Córregos e Bairros monitorados do Mapa
/// Hidrológico do Portal Administrador.
///
/// TODO(GEOPRAG-24): contrato real dos endpoints ainda não validado com o
/// backend.
abstract class CorregoRepository {
  Future<List<Corrego>> listar();
  Future<Corrego> buscarPorId(String id);

  Future<List<Bairro>> listarBairros();
  Future<Bairro> buscarBairroPorId(String id);
  Future<List<Corrego>> listarCorregosDoBairro(String bairroId);
}
