import 'recebimento_view_model.dart';

sealed class RecebimentoConfirmacaoState {
  const RecebimentoConfirmacaoState();
}

class RecebimentoConfirmacaoLoading extends RecebimentoConfirmacaoState {
  const RecebimentoConfirmacaoLoading();
}

class RecebimentoConfirmacaoLoaded extends RecebimentoConfirmacaoState {
  final RecebimentoDetalheViewModel recebimento;
  const RecebimentoConfirmacaoLoaded(this.recebimento);
}

class RecebimentoConfirmacaoError extends RecebimentoConfirmacaoState {
  final String message;
  const RecebimentoConfirmacaoError(this.message);
}
