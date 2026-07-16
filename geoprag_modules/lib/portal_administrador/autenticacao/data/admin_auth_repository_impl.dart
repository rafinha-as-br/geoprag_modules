import '../core/admin_account.dart';
import '../core/admin_auth_repository.dart';
import 'mock_admin_accounts.dart';

/// Implementação mockada de [AdminAuthRepository] — resolve contra
/// [mockAdminAccounts], sem chamada de rede real.
///
/// TODO(GEOPRAG-24): substituir por implementação real assim que o contrato
/// de endpoints de auth (GEOPRAG-22) for validado com o backend.
class AdminAuthRepositoryImpl implements AdminAuthRepository {
  @override
  Future<AdminAccount> login({
    required String identifier,
    required String senha,
  }) async {
    return mockAdminAccounts.first;
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
  Future<void> resetPassword({required String novaSenha}) async {}
}
