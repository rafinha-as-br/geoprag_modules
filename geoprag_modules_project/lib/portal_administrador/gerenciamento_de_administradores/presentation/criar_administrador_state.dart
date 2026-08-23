import '../../autenticacao/core/admin_account.dart';

/// Estado da submissão do formulário de criação de novo administrador
/// (GEOPRAG-36) — ação única, mesma forma de idle/loading/sucesso/erro do
/// fluxo de autenticação, mas modelado localmente porque criar um
/// administrador não é, em si, uma ação de autenticação.
sealed class CriarAdministradorState {
  const CriarAdministradorState();
}

class CriarAdministradorIdle extends CriarAdministradorState {
  const CriarAdministradorIdle();
}

class CriarAdministradorSalvando extends CriarAdministradorState {
  const CriarAdministradorSalvando();
}

class CriarAdministradorSucesso extends CriarAdministradorState {
  final AdminAccount conta;

  /// Senha inicial gerada automaticamente (GEOPRAG-61/68) — exibida em tela
  /// uma única vez para quem cadastrou repassar verbalmente ao novo usuário.
  final String senhaGerada;

  const CriarAdministradorSucesso(this.conta, this.senhaGerada);
}

class CriarAdministradorErro extends CriarAdministradorState {
  final String message;
  const CriarAdministradorErro(this.message);
}
