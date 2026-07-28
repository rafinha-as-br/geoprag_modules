import '../../autenticacao/core/admin_account.dart';

/// Contrato de criação de novos usuários administradores do Portal
/// Administrador (GEOPRAG-36). Todo cadastro novo nasce como
/// [AdminRole.subAdministrador] — não existe seleção de cargo no formulário
/// de criação; a elevação a [AdminRole.administrador] só ocorre por
/// promoção (fora do escopo desta issue, ver GEOPRAG-34/GEOPRAG-47).
///
/// TODO(GEOPRAG-36): validação de permissão (403 se quem chama não tiver
/// cargo Administrador) é responsabilidade do backend — não há repositório
/// `geoprag_api` conectado nesta sessão de trabalho para implementar aqui.
abstract class AdministradorRepository {
  Future<AdminAccount> criar({required String email, required String nome});
}
