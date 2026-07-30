import '../../autenticacao/core/admin_account.dart';
import '../../autenticacao/data/mock_admin_accounts.dart';
import '../core/administrador_repository.dart';
import '../../../src/errors/app_exceptions.dart';

/// Implementação mockada de [AdministradorRepository] — adiciona a nova
/// conta à lista mockada compartilhada com o fluxo de autenticação
/// (`mockAdminAccounts`), de onde o login (`AdminAuthRepositoryImpl`) lê.
///
/// TODO(GEOPRAG-36): substituir por implementação HTTP real quando o
/// contrato de endpoints deste módulo for validado com o backend.
class AdministradorRepositoryImpl implements AdministradorRepository {
  @override
  Future<AdminAccount> criar({
    required String email,
    required String nome,
    required String cpf,
    required DateTime dataNascimento,
    required String sexo,
  }) async {
    final jaExiste = mockAdminAccounts.any((conta) => conta.email == email);
    if (jaExiste) {
      throw EntidadeDuplicadaException(
        'Já existe um administrador cadastrado com o e-mail "$email".',
      );
    }

    final conta = AdminAccount(
      email: email,
      nome: nome,
      cpf: cpf,
      dataNascimento: dataNascimento,
      sexo: sexo,
      role: AdminRole.subAdministrador,
    );
    mockAdminAccounts.add(conta);
    return conta;
  }
}
