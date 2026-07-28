import 'denuncia_de_foco.dart';

/// Contrato de acesso aos dados de Denúncias de Foco do `aplicador_app`.
///
/// TODO(GEOPRAG-24): contrato real dos endpoints ainda não validado com o
/// backend.
abstract class DenunciaDeFocoRepository {
  Future<List<DenunciaDeFoco>> listar();

  Future<DenunciaDeFoco> registrar({
    required NivelInfestacaoFoco nivelInfestacao,
    required String localDescricao,
    String? observacoes,
  });
}
