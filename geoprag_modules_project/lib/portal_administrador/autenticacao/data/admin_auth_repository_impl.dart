import '../core/admin_account.dart';
import '../core/admin_auth_exceptions.dart';
import '../core/admin_auth_repository.dart';
import 'mock_admin_accounts.dart';

/// Implementação mockada de [AdminAuthRepository] — resolve contra
/// [mockAdminAccounts] (+ [mockSenha]) e simula tanto sucesso quanto falha
/// (401) do contrato de `POST /auth/login`, sem chamada de rede real.
///
/// TODO(GEOPRAG-30/GEOPRAG-24): substituir por implementação real (HTTP com
/// cookie `HttpOnly`/`withCredentials`) assim que o contrato de endpoints de
/// auth (GEOPRAG-22) for validado com o backend.
class AdminAuthRepositoryImpl implements AdminAuthRepository {
  @override
  Future<AdminAccount> login({
    required String identifier,
    required String senha,
  }) async {
    final normalized = identifier.trim().toLowerCase();
    for (final account in mockAdminAccounts) {
      if (account.email.toLowerCase() == normalized &&
          senha == mockAdminSenha) {
        return account;
      }
    }
    throw const InvalidCredentialsException();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<AdminAccount?> findByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    for (final account in mockAdminAccounts) {
      if (account.email.toLowerCase() == normalized) return account;
    }
    return null;
  }

  @override
  Future<void> verifyResetCode({required String code}) async {}

  @override
  Future<void> resetPassword({required String novaSenha}) async {}
}
