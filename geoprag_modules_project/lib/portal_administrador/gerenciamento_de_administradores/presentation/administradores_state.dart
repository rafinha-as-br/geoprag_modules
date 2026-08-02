import 'administrador_view_model.dart';

sealed class AdministradoresState {
  const AdministradoresState();
}

class AdministradoresLoading extends AdministradoresState {
  const AdministradoresLoading();
}

class AdministradoresError extends AdministradoresState {
  final String message;
  const AdministradoresError(this.message);
}

class AdministradoresLoaded extends AdministradoresState {
  final List<AdministradorViewModel> administradores;

  /// Mensagem de retorno da última ação (desativar/solicitar promoção) —
  /// sucesso ou erro de negócio, para exibição em `SnackBar`. `null` quando
  /// o estado veio de um carregamento inicial, sem ação associada.
  final String? avisoAcao;

  const AdministradoresLoaded(this.administradores, {this.avisoAcao});
}
