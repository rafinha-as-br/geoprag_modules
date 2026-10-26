import '../../../src/api/api_client.dart';
import '../../../src/api/auth/auth_mappers.dart';
import '../../../src/api/auth/login_dtos.dart';
import '../../../src/api/auth/usuario_dto.dart';
import '../../../src/api/sessao_segura.dart';
import '../core/auth_exceptions.dart';
import '../core/auth_repository.dart';
import '../core/usuario.dart';

/// [AuthRepository] sobre a API real (GEOPRAG-187).
///
/// Login em `POST /auth/login` (público), tokens e usuário guardados na
/// [SessaoSegura]. A recuperação de senha segue simulada: o contrato v0 não
/// tem endpoint para ela.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required ApiClient api,
    required SessaoSegura sessao,
    DateTime Function()? agora,
  }) : _api = api,
       _sessao = sessao,
       _agora = agora ?? DateTime.now;

  final ApiClient _api;
  final SessaoSegura _sessao;
  final DateTime Function() _agora;

  @override
  Future<Usuario> login({
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
    if (resposta.usuario.perfil != PerfilDto.aplicador) {
      // Conta de outro perfil não entra no App Aplicador, e nada dela fica
      // guardado no aparelho.
      throw const InvalidCredentialsException();
    }
    await _sessao.iniciar(resposta, agora: _agora());
    return AuthMappers.paraUsuarioDoAplicador(resposta.usuario);
  }

  @override
  Future<void> logout() => _sessao.limpar();

  @override
  Future<Usuario?> sessaoAtual() async {
    final salva = await _sessao.restaurar();
    if (salva == null) return null;
    // O refresh token mantém o aplicador logado por 30 dias; sem ele, o
    // access token curto não sustenta uma sessão aberta offline.
    if (salva.usuario.perfil != PerfilDto.aplicador || !salva.temRefreshToken) {
      await _sessao.limpar();
      return null;
    }
    return AuthMappers.paraUsuarioDoAplicador(salva.usuario);
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {}

  @override
  Future<void> verifyResetCode({required String code}) async {}

  @override
  Future<void> resetPassword({required String novaSenha}) async {}
}
