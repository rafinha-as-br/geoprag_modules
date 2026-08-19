import 'aplicacao_view_model.dart';

sealed class AplicacaoAtualState {
  const AplicacaoAtualState();
}

class AplicacaoAtualLoading extends AplicacaoAtualState {
  const AplicacaoAtualLoading();
}

class AplicacaoAtualLoaded extends AplicacaoAtualState {
  final AplicacaoAtualViewModel aplicacao;
  const AplicacaoAtualLoaded(this.aplicacao);
}

class AplicacaoAtualError extends AplicacaoAtualState {
  final String message;
  const AplicacaoAtualError(this.message);
}
