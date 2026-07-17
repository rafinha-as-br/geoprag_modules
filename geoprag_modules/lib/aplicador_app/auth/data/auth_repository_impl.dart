import '../core/auth_exceptions.dart';
import '../core/auth_repository.dart';
import '../core/user.dart';
import 'mock_users.dart';

/// Implementação mockada de [AuthRepository] — autentica contra [mockUsers]
/// (+ [mockSenha]) e simula tanto sucesso quanto falha (401) do contrato de
/// `POST /auth/login`, sem chamada de rede real.
///
/// TODO(GEOPRAG-30/GEOPRAG-24): substituir por implementação real (HTTP +
/// persistência de token via `flutter_secure_storage` + `public_key` do
/// dispositivo) assim que o contrato de endpoints de auth (GEOPRAG-22) e a
/// decisão de geração de chaves assimétricas forem fechados com o backend.
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<User> login({
    required String identifier,
    required String senha,
  }) async {
    final normalized = identifier.trim();
    for (final user in mockUsers) {
      if (user.cpf == normalized && senha == mockUserSenha) return user;
    }
    throw const InvalidCredentialsException();
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
