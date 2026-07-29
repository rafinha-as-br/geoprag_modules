import 'ponto_de_aplicacao_view_model.dart';

sealed class PontoDeAplicacaoState {
  const PontoDeAplicacaoState();
}

class PontoDeAplicacaoLoading extends PontoDeAplicacaoState {
  const PontoDeAplicacaoLoading();
}

class PontoDeAplicacaoLoaded extends PontoDeAplicacaoState {
  final PontoDeAplicacaoViewModel ponto;
  const PontoDeAplicacaoLoaded(this.ponto);
}

class PontoDeAplicacaoError extends PontoDeAplicacaoState {
  final String message;
  const PontoDeAplicacaoError(this.message);
}
