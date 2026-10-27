import 'usuario.dart';

/// Contrato do fluxo de autenticação do Aplicador (login + recuperação de
/// senha em 3 passos: solicitar código, verificar código, recriar senha).
///
/// Login, logout e restauração da sessão falam com a API real
/// (`POST /auth/login`, GEOPRAG-187). A recuperação de senha continua sem
/// endpoint no contrato v0 e segue simulada.
abstract class AuthRepository {
  /// Autentica por CPF ou e-mail. Guarda a sessão no aparelho e devolve o
  /// usuário, com `id` e `tenantId` vindos do servidor.
  ///
  /// Lança [InvalidCredentialsException] se o perfil não é de aplicador, e as
  /// exceções da API (`ApiException`) para credenciais recusadas, usuário
  /// desativado, falta de rede etc.
  Future<Usuario> login({required String identifier, required String senha});

  /// Encerra a sessão local (apaga tokens e usuário do aparelho).
  Future<void> logout();

  /// Sessão guardada no aparelho, sem chamar a rede (o aplicador precisa abrir
  /// o app offline). `null` quando não há sessão utilizável.
  Future<Usuario?> sessaoAtual();

  Future<void> requestPasswordReset({required String email});
  Future<void> verifyResetCode({required String code});
  Future<void> resetPassword({required String novaSenha});
}
