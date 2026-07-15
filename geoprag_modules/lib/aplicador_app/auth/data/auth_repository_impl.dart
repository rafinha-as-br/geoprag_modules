import '../core/auth_repository.dart';
import '../core/user.dart';
import 'mock_users.dart';

/// Implementação mockada de [AuthRepository] — sempre autentica com sucesso
/// contra [mockUsers], sem chamada de rede real.
///
/// TODO(GEOPRAG-24): substituir por implementação real assim que o contrato
/// de endpoints de auth (GEOPRAG-22) for validado com o backend.
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<User> login({
    required String identifier,
    required String senha,
  }) async {
    return mockUsers.first;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> requestPasswordReset({required String email}) async {}

  @override
  Future<void> verifyResetCode({required String code}) async {}

  @override
  Future<void> resetPassword({required String novaSenha}) async {}
}
