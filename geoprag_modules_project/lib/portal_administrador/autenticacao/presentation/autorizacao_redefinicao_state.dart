import 'solicitacao_redefinicao_view_model.dart';

sealed class AutorizacaoRedefinicaoState {
  const AutorizacaoRedefinicaoState();
}

class AutorizacaoRedefinicaoLoading extends AutorizacaoRedefinicaoState {
  const AutorizacaoRedefinicaoLoading();
}

class AutorizacaoRedefinicaoLoaded extends AutorizacaoRedefinicaoState {
  final SolicitacaoRedefinicaoViewModel solicitacao;
  const AutorizacaoRedefinicaoLoaded(this.solicitacao);
}

class AutorizacaoRedefinicaoError extends AutorizacaoRedefinicaoState {
  final String message;
  const AutorizacaoRedefinicaoError(this.message);
}
