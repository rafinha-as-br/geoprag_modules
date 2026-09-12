import 'corrego_view_model.dart';

sealed class CorregoDetalheState {
  const CorregoDetalheState();
}

class CorregoDetalheLoading extends CorregoDetalheState {
  const CorregoDetalheLoading();
}

class CorregoDetalheLoaded extends CorregoDetalheState {
  final CorregoDetalhadoViewModel corrego;
  const CorregoDetalheLoaded(this.corrego);
}

class CorregoDetalheError extends CorregoDetalheState {
  final String message;
  const CorregoDetalheError(this.message);
}
