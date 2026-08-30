import 'admin_account.dart';

/// Contrato do fluxo de autenticação do Portal Administrador: login e
/// recuperação de senha, cujo restante do fluxo depende do papel da conta
/// (Administrador principal vs. Sub-Administrador — ver [AdminRole]).
///
/// TODO(GEOPRAG-24): contrato real dos endpoints ainda não validado com o
/// backend — ver "Contrato de Endpoints — Módulo Autenticação" (GEOPRAG-22).
abstract class AdminAuthRepository {
  Future<AdminAccount> login({
    required String identifier,
    required String senha,
  });
  Future<void> logout();

  /// Usado pelo fluxo "esqueci minha senha" para decidir, pelo papel da
  /// conta, se a redefinição segue direto (Administrador) ou precisa de
  /// autorização prévia (Sub-Administrador).
  Future<AdminAccount?> findByEmail(String email);

  /// Usado por `verificar_codigo_admin_screen.dart` e
  /// `verificar_codigo_sub_admin_screen.dart` para confirmar o código de 6
  /// dígitos antes de liberar a recriação de senha.
  Future<void> verifyResetCode({required String code});

  Future<void> resetPassword({required String novaSenha});
}
