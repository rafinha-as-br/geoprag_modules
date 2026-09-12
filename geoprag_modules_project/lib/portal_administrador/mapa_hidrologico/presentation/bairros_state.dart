import 'bairro_view_model.dart';

sealed class BairrosState {
  const BairrosState();
}

class BairrosLoading extends BairrosState {
  const BairrosLoading();
}

class BairrosLoaded extends BairrosState {
  final List<BairroResumoViewModel> bairros;
  const BairrosLoaded(this.bairros);
}

class BairrosError extends BairrosState {
  final String message;
  const BairrosError(this.message);
}
