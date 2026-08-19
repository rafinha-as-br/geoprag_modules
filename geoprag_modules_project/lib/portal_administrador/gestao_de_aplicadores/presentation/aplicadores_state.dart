import 'aplicador_view_model.dart';

sealed class AplicadoresState {
  const AplicadoresState();
}

class AplicadoresLoading extends AplicadoresState {
  const AplicadoresLoading();
}

class AplicadoresLoaded extends AplicadoresState {
  final List<AplicadorResumoViewModel> aplicadores;
  const AplicadoresLoaded(this.aplicadores);
}

class AplicadoresError extends AplicadoresState {
  final String message;
  const AplicadoresError(this.message);
}
