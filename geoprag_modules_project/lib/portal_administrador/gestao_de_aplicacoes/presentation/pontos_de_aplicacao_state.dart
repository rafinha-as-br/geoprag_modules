import 'view_models/ponto_de_aplicacao_resumo_view_model.dart';

sealed class PontosDeAplicacaoState {
  const PontosDeAplicacaoState();
}

class PontosDeAplicacaoLoading extends PontosDeAplicacaoState {
  const PontosDeAplicacaoLoading();
}

class PontosDeAplicacaoLoaded extends PontosDeAplicacaoState {
  final List<PontoDeAplicacaoResumoViewModel> pontos;
  const PontosDeAplicacaoLoaded(this.pontos);
}

class PontosDeAplicacaoError extends PontosDeAplicacaoState {
  final String message;
  const PontosDeAplicacaoError(this.message);
}
