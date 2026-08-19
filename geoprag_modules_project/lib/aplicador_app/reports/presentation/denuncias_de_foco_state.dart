import 'denuncia_de_foco_view_model.dart';

sealed class DenunciasDeFocoState {
  const DenunciasDeFocoState();
}

class DenunciasDeFocoLoading extends DenunciasDeFocoState {
  const DenunciasDeFocoLoading();
}

class DenunciasDeFocoLoaded extends DenunciasDeFocoState {
  final List<DenunciaDeFocoViewModel> denuncias;
  const DenunciasDeFocoLoaded(this.denuncias);
}

class DenunciasDeFocoError extends DenunciasDeFocoState {
  final String message;
  const DenunciasDeFocoError(this.message);
}
