import 'recebimento_view_model.dart';

sealed class RecebimentosState {
  const RecebimentosState();
}

class RecebimentosLoading extends RecebimentosState {
  const RecebimentosLoading();
}

class RecebimentosLoaded extends RecebimentosState {
  final List<RecebimentoResumoViewModel> recebimentos;
  const RecebimentosLoaded(this.recebimentos);
}

class RecebimentosError extends RecebimentosState {
  final String message;
  const RecebimentosError(this.message);
}
