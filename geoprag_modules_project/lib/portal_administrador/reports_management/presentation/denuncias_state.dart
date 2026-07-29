import 'denuncia_view_model.dart';

sealed class DenunciasState {
  const DenunciasState();
}

class DenunciasLoading extends DenunciasState {
  const DenunciasLoading();
}

class DenunciasLoaded extends DenunciasState {
  final List<DenunciaResumoViewModel> denuncias;
  const DenunciasLoaded(this.denuncias);
}

class DenunciasError extends DenunciasState {
  final String message;
  const DenunciasError(this.message);
}
