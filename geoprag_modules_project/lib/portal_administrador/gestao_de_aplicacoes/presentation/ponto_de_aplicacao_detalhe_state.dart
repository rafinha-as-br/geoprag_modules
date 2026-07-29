import 'view_models/ponto_de_aplicacao_detalhe_view_model.dart';

sealed class PontoDeAplicacaoDetalheState {
  const PontoDeAplicacaoDetalheState();
}

class PontoDeAplicacaoDetalheLoading extends PontoDeAplicacaoDetalheState {
  const PontoDeAplicacaoDetalheLoading();
}

class PontoDeAplicacaoDetalheLoaded extends PontoDeAplicacaoDetalheState {
  final PontoDeAplicacaoDetalheViewModel ponto;
  const PontoDeAplicacaoDetalheLoaded(this.ponto);
}

class PontoDeAplicacaoDetalheError extends PontoDeAplicacaoDetalheState {
  final String message;
  const PontoDeAplicacaoDetalheError(this.message);
}
