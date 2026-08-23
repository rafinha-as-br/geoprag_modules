import 'solicitacao_promocao_view_model.dart';

sealed class SolicitacoesPromocaoState {
  const SolicitacoesPromocaoState();
}

class SolicitacoesPromocaoLoading extends SolicitacoesPromocaoState {
  const SolicitacoesPromocaoLoading();
}

class SolicitacoesPromocaoError extends SolicitacoesPromocaoState {
  final String message;
  const SolicitacoesPromocaoError(this.message);
}

class SolicitacoesPromocaoLoaded extends SolicitacoesPromocaoState {
  final List<SolicitacaoPromocaoViewModel> solicitacoes;

  /// Mensagem de retorno da última ação (votar/cancelar) — sucesso ou erro
  /// de negócio, para exibição em `SnackBar`.
  final String? avisoAcao;

  const SolicitacoesPromocaoLoaded(this.solicitacoes, {this.avisoAcao});
}
