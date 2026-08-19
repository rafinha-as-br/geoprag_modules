import 'denuncia_view_model.dart';

sealed class DenunciaDetalheState {
  const DenunciaDetalheState();
}

class DenunciaDetalheLoading extends DenunciaDetalheState {
  const DenunciaDetalheLoading();
}

class DenunciaDetalheLoaded extends DenunciaDetalheState {
  final DenunciaDetalhadaViewModel denuncia;
  const DenunciaDetalheLoaded(this.denuncia);
}

class DenunciaDetalheError extends DenunciaDetalheState {
  final String message;
  const DenunciaDetalheError(this.message);
}
