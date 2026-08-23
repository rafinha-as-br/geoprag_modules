import '../core/aplicador.dart';

/// Estado da submissão do formulário de criação de novo Aplicador
/// (GEOPRAG-65) — mesma forma de idle/salvando/sucesso/erro já usada no
/// fluxo equivalente de Administrador (ver [CriarAdministradorState]).
sealed class CriarAplicadorState {
  const CriarAplicadorState();
}

class CriarAplicadorIdle extends CriarAplicadorState {
  const CriarAplicadorIdle();
}

class CriarAplicadorSalvando extends CriarAplicadorState {
  const CriarAplicadorSalvando();
}

class CriarAplicadorSucesso extends CriarAplicadorState {
  final Aplicador aplicador;

  /// Senha inicial gerada automaticamente (GEOPRAG-61/65) — exibida em tela
  /// uma única vez para quem cadastrou repassar verbalmente ao novo usuário.
  final String senhaGerada;

  const CriarAplicadorSucesso(this.aplicador, this.senhaGerada);
}

class CriarAplicadorErro extends CriarAplicadorState {
  final String message;
  const CriarAplicadorErro(this.message);
}
