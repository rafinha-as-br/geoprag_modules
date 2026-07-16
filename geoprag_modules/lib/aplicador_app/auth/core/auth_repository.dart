import 'user.dart';

/// Contrato do fluxo de autenticação do Aplicador (login + recuperação de
/// senha em 3 passos: solicitar código, verificar código, recriar senha).
///
/// TODO(GEOPRAG-24): contrato real dos endpoints ainda não validado com o
/// backend — ver "Contrato de Endpoints — Módulo Autenticação" (GEOPRAG-22).
abstract class AuthRepository {
  Future<User> login({required String identifier, required String senha});
  Future<void> logout();

  Future<void> requestPasswordReset({required String email});
  Future<void> verifyResetCode({required String code});
  Future<void> resetPassword({required String novaSenha});
}
