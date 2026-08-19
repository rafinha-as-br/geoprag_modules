import 'aplicador.dart';
import 'atuacao_aplicador.dart';

/// Contrato de acesso aos dados de Aplicadores (voluntários cadastrados) do
/// Portal Administrador.
///
/// TODO(GEOPRAG-24): contrato real dos endpoints ainda não validado com o
/// backend.
abstract class AplicadorRepository {
  Future<List<Aplicador>> listar();
  Future<Aplicador> buscarPorId(String id);
  Future<List<AtuacaoAplicador>> buscarHistorico(String aplicadorId);
}
