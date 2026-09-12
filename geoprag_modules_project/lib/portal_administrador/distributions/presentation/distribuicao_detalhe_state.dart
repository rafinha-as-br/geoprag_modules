import 'distribuicao_view_model.dart';

sealed class DistribuicaoDetalheState {
  const DistribuicaoDetalheState();
}

class DistribuicaoDetalheLoading extends DistribuicaoDetalheState {
  const DistribuicaoDetalheLoading();
}

class DistribuicaoDetalheLoaded extends DistribuicaoDetalheState {
  final DistribuicaoDetalhadaViewModel distribuicao;
  const DistribuicaoDetalheLoaded(this.distribuicao);
}

class DistribuicaoDetalheError extends DistribuicaoDetalheState {
  final String message;
  const DistribuicaoDetalheError(this.message);
}
