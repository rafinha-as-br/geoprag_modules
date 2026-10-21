import 'admin_account.dart';

/// Contrato do fluxo de autenticação do Portal Administrador: login e
/// recuperação de senha, cujo restante do fluxo depende do papel da conta
/// (Administrador principal vs. Sub-Administrador — ver [AdminRole]).
///
/// Login, logout e restauração da sessão falam com a API real
/// (`POST /auth/login`, GEOPRAG-187). O restante do fluxo de senha continua
/// simulado: o contrato v0 não tem endpoints para ele.
abstract class AdminAuthRepository {
  /// Autentica por e-mail (ou CPF). Guarda a sessão no navegador e devolve a
  /// conta, com `id` e `tenantId` vindos do servidor.
  ///
  /// Lança [InvalidCredentialsException] se a conta é de um aplicador, e as
  /// exceções da API (`ApiException`) para credenciais recusadas, usuário
  /// desativado, falta de rede etc.
  Future<AdminAccount> login({
    required String identifier,
    required String senha,
  });

  /// Encerra a sessão local (apaga token e conta guardados).
  Future<void> logout();

  /// Sessão guardada no navegador, ainda dentro da validade do access token
  /// (o portal não tem refresh token). `null` quando não há sessão utilizável.
  Future<AdminAccount?> sessaoAtual();

  /// Usado pelo fluxo "esqueci minha senha" para decidir, pelo papel da
  /// conta, se a redefinição segue direto (Administrador) ou precisa de
  /// autorização prévia (Sub-Administrador).
  Future<AdminAccount?> findByEmail(String email);

  /// Usado por `verificar_codigo_admin_screen.dart` e
  /// `verificar_codigo_sub_admin_screen.dart` para confirmar o código de 6
  /// dígitos antes de liberar a recriação de senha.
  Future<void> verifyResetCode({required String code});

  Future<void> resetPassword({required String novaSenha});

  /// Troca de senha a partir da própria tela de dados do administrador
  /// logado (GEOPRAG-148) — diferente de [resetPassword] (fluxo "esqueci
  /// minha senha", sem senha atual para conferir), exige [senhaAtual]
  /// correta antes de aceitar [novaSenha].
  Future<void> alterarSenha({
    required String senhaAtual,
    required String novaSenha,
  });
}
