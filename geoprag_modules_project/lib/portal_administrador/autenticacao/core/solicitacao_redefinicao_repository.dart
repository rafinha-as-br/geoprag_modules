import 'solicitacao_redefinicao.dart';

/// Contrato do fluxo de autorização de redefinição de senha do
/// Sub-Administrador: busca a solicitação pendente e registra a decisão do
/// Administrador principal (autorizar/negar).
///
/// TODO(GEOPRAG-24): contrato real dos endpoints ainda não validado com o
/// backend — ver "Contrato de Endpoints — Módulo Autenticação" (GEOPRAG-22).
abstract class SolicitacaoRedefinicaoRepository {
  Future<SolicitacaoRedefinicao> buscarPendente();
  Future<SolicitacaoRedefinicao> autorizar(String id);
  Future<SolicitacaoRedefinicao> negar(String id);
}
