/// Contrato único de "feedback pós-ação" (sucesso/erro de uma ação disparada
/// pelo usuário, ex.: submeter formulário, ativar/desativar registro) para os
/// templates de tela do pacote — decisão registrada em GEOPRAG-77.
///
/// Antes desta decisão coexistiam 2 modelos no pacote: hierarquias de estado
/// dedicadas por Cubit (ex. `AuthActionSuccess`/`AuthActionFailure`,
/// `CriarAplicadorSucesso`/`CriarAplicadorErro`) e um campo `avisoAcao:
/// String?` adicionado ao estado `Loaded` de outros Cubits (ex.
/// `AdministradoresLoaded`, `SolicitacoesPromocaoLoaded`). Nenhum dos dois
/// modelos permitia à UI diferenciar sucesso de erro a partir do próprio
/// dado — um `String?` não carrega essa semântica, e cada hierarquia de ação
/// dedicada era reimplementada do zero por feature em vez de reaproveitada.
///
/// Os templates `BaseListScreen` e `BaseFormScreen` (GEOPRAG-83/GEOPRAG-86)
/// devem expor o resultado da última ação como `AcaoFeedback?` — em vez de
/// `String?` — para poder estilizar o `SnackBar`/aviso de acordo com
/// [AcaoFeedbackSucesso] ou [AcaoFeedbackErro] sem inspecionar a mensagem.
sealed class AcaoFeedback {
  final String mensagem;

  const AcaoFeedback(this.mensagem);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AcaoFeedback &&
          other.runtimeType == runtimeType &&
          other.mensagem == mensagem);

  @override
  int get hashCode => Object.hash(runtimeType, mensagem);
}

/// Resultado de sucesso de uma ação (ex.: "Administrador desativado com
/// sucesso.").
class AcaoFeedbackSucesso extends AcaoFeedback {
  const AcaoFeedbackSucesso(super.mensagem);
}

/// Resultado de erro de uma ação (ex.: "Não foi possível desativar o
/// administrador.").
class AcaoFeedbackErro extends AcaoFeedback {
  const AcaoFeedbackErro(super.mensagem);
}
