/// Levantada por [AdminAuthRepository.login] quando as credenciais informadas
/// não conferem — equivalente ao `401` do contrato de `POST /auth/login`
/// (ver "Contrato de Endpoints — Módulo Autenticação", GEOPRAG-22).
class InvalidCredentialsException implements Exception {
  const InvalidCredentialsException();
}
