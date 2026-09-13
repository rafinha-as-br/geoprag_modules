import 'detalhe_do_ponto_view_model.dart';

sealed class DetalheDoPontoDesignadoState {
  const DetalheDoPontoDesignadoState();
}

class DetalheDoPontoDesignadoLoading extends DetalheDoPontoDesignadoState {
  const DetalheDoPontoDesignadoLoading();
}

class DetalheDoPontoDesignadoLoaded extends DetalheDoPontoDesignadoState {
  final DetalheDoPontoDesignadoViewModel ponto;
  const DetalheDoPontoDesignadoLoaded(this.ponto);
}

class DetalheDoPontoDesignadoError extends DetalheDoPontoDesignadoState {
  final String message;
  const DetalheDoPontoDesignadoError(this.message);
}
