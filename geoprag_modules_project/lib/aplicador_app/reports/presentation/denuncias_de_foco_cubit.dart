import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/denuncia_de_foco_repository.dart';
import 'denuncia_de_foco_view_model.dart';
import 'denuncias_de_foco_state.dart';

/// Carrega a listagem de Denúncias de Foco registradas pelo aplicador para
/// o seu dashboard.
class DenunciasDeFocoCubit extends Cubit<DenunciasDeFocoState> {
  DenunciasDeFocoCubit(this._repository)
    : super(const DenunciasDeFocoLoading()) {
    _carregar();
  }

  final DenunciaDeFocoRepository _repository;

  Future<void> _carregar() async {
    try {
      final denuncias = await _repository.listar();
      emit(
        DenunciasDeFocoLoaded(
          denuncias.map(DenunciaDeFocoViewModel.fromEntity).toList(),
        ),
      );
    } catch (e) {
      emit(DenunciasDeFocoError('Não foi possível carregar os dados. Tente novamente.'));
    }
  }
}
