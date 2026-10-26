import '../../../src/api/api_client.dart';
import '../../../src/api/auth/auth_mappers.dart';
import '../../../src/api/auth/login_dtos.dart';
import '../../../src/api/auth/usuario_dto.dart';
import '../../../src/api/sessao_segura.dart';
import '../core/admin_account.dart';
import '../core/admin_auth_exceptions.dart';
import '../core/admin_auth_repository.dart';
import 'mock_admin_accounts.dart';

/// [AdminAuthRepository] sobre a API real (GEOPRAG-187).
///
/// Login em `POST /auth/login` (público), token e conta guardados na
/// [SessaoSegura]. Os demais métodos (`findByEmail`, código de verificação,
/// redefinição e troca de senha) seguem simulados sobre [mockAdminAccounts]:
/// o contrato v0 não tem endpoints para eles.
class AdminAuthRepositoryImpl implements AdminAuthRepository {
  AdminAuthRepositoryImpl({
    required ApiClient api,
    required SessaoSegura sessao,
    DateTime Function()? agora,
  }) : _api = api,
       _sessao = sessao,
       _agora = agora ?? DateTime.now;

  /// Folga na validade do access token ao reabrir o portal: evita restaurar uma
  /// sessão que expira em segundos.
  static const Duration margemDeExpiracao = Duration(seconds: 30);

  final ApiClient _api;
  final SessaoSegura _sessao;
  final DateTime Function() _agora;

  @override
  Future<AdminAccount> login({
    required String identifier,
    required String senha,
  }) async {
    final corpo = await _api.post(
      LoginRequestDto.caminho,
      corpo: LoginRequestDto(
        identificador: identifier.trim(),
        senha: senha,
      ).toJson(),
      autenticado: false,
    );
    final resposta = LoginResponseDto.fromCorpo(corpo);
    if (resposta.usuario.perfil == PerfilDto.aplicador) {
      // Conta de aplicador não entra no portal, e nada dela fica guardado.
      throw const InvalidCredentialsException();
    }
    await _sessao.iniciar(resposta, agora: _agora());
    return AuthMappers.paraAdminAccount(resposta.usuario);
  }

  @override
  Future<void> logout() => _sessao.limpar();

  @override
  Future<AdminAccount?> sessaoAtual() async {
    final salva = await _sessao.restaurar();
    if (salva == null) return null;
    if (salva.usuario.perfil == PerfilDto.aplicador ||
        salva.accessTokenExpirado(_agora(), margem: margemDeExpiracao)) {
      await _sessao.limpar();
      return null;
    }
    return AuthMappers.paraAdminAccount(salva.usuario);
  }

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

  @override
  Future<void> alterarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    if (senhaAtual != mockAdminSenha) {
      throw const InvalidCredentialsException();
    }
  }
}
