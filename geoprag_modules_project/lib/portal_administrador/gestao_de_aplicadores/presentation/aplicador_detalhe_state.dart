import 'aplicador_view_model.dart';

sealed class AplicadorDetalheState {
  const AplicadorDetalheState();
}

class AplicadorDetalheLoading extends AplicadorDetalheState {
  const AplicadorDetalheLoading();
}

class AplicadorDetalheLoaded extends AplicadorDetalheState {
  final AplicadorDetalhadoViewModel aplicador;
  const AplicadorDetalheLoaded(this.aplicador);
}

class AplicadorDetalheError extends AplicadorDetalheState {
  final String message;
  const AplicadorDetalheError(this.message);
}
