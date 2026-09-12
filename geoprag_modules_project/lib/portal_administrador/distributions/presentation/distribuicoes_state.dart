import 'distribuicao_view_model.dart';

sealed class DistribuicoesState {
  const DistribuicoesState();
}

class DistribuicoesLoading extends DistribuicoesState {
  const DistribuicoesLoading();
}

class DistribuicoesLoaded extends DistribuicoesState {
  final List<DistribuicaoResumoViewModel> distribuicoes;
  const DistribuicoesLoaded(this.distribuicoes);
}

class DistribuicoesError extends DistribuicoesState {
  final String message;
  const DistribuicoesError(this.message);
}
