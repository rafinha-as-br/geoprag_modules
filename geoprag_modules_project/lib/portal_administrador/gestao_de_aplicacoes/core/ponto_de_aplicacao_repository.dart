import 'ponto_de_aplicacao.dart';

/// Contrato de acesso aos dados de Pontos de Aplicação química do Portal
/// Administrador (GEOPRAG-38).
///
/// TODO(GEOPRAG-38): contrato real dos endpoints ainda não validado com o
/// backend.
abstract class AdminPontoDeAplicacaoRepository {
  Future<List<AdminPontoDeAplicacao>> listar();
  Future<AdminPontoDeAplicacao> buscarPorId(String id);

  /// Cria um novo ponto — nasce sempre como [StatusPontoDeAplicacao.planejada]
  /// e não exige [aplicadorId] (pode ficar sem aplicador até atribuição
  /// posterior).
  Future<AdminPontoDeAplicacao> criar({
    required String bairro,
    required double lat,
    required double lng,
    String? aplicadorId,
  });

  /// Atribui (ou remove, passando `null`) o aplicador responsável pelo ponto.
  Future<AdminPontoDeAplicacao> atribuirAplicador(String id, String? aplicadorId);

  /// Desativação lógica — um ponto nunca é excluído, apenas desativado.
  Future<AdminPontoDeAplicacao> desativar(String id);

  /// Edita os dados de localização do ponto (bairro, latitude, longitude).
  /// Não altera status, ativo ou aplicador — cada um tem seu próprio fluxo.
  Future<AdminPontoDeAplicacao> editar(
    String id, {
    required String bairro,
    required double lat,
    required double lng,
  });
}
