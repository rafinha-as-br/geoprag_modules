import 'bairro_view_model.dart';

sealed class BairroDetalheState {
  const BairroDetalheState();
}

class BairroDetalheLoading extends BairroDetalheState {
  const BairroDetalheLoading();
}

class BairroDetalheLoaded extends BairroDetalheState {
  final BairroDetalhadoViewModel bairro;
  const BairroDetalheLoaded(this.bairro);
}

class BairroDetalheError extends BairroDetalheState {
  final String message;
  const BairroDetalheError(this.message);
}
