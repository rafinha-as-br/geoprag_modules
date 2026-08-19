import 'aplicacao_mapa_view_model.dart';

sealed class AplicacaoMapaState {
  const AplicacaoMapaState();
}

class AplicacaoMapaLoading extends AplicacaoMapaState {
  const AplicacaoMapaLoading();
}

class AplicacaoMapaLoaded extends AplicacaoMapaState {
  final AplicacaoMapaViewModel aplicacao;
  const AplicacaoMapaLoaded(this.aplicacao);
}

class AplicacaoMapaError extends AplicacaoMapaState {
  final String message;
  const AplicacaoMapaError(this.message);
}
