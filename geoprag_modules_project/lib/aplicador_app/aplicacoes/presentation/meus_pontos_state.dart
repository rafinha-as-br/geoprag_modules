import 'meus_pontos_view_model.dart';

sealed class MeusPontosState {
  const MeusPontosState();
}

class MeusPontosLoading extends MeusPontosState {
  const MeusPontosLoading();
}

class MeusPontosLoaded extends MeusPontosState {
  final List<PontoDoAplicadorResumoViewModel> pontos;
  const MeusPontosLoaded(this.pontos);
}

class MeusPontosError extends MeusPontosState {
  final String message;
  const MeusPontosError(this.message);
}
