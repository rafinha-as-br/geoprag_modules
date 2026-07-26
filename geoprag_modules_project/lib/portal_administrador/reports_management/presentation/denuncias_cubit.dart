import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/denuncia_repository.dart';
import 'denuncia_view_model.dart';
import 'denuncias_state.dart';

/// Carrega a listagem de Denúncias registradas para o dashboard de triagem
/// e para a listagem completa.
class DenunciasCubit extends Cubit<DenunciasState> {
  DenunciasCubit(this._repository) : super(const DenunciasLoading()) {
    _carregar();
  }

  final DenunciaRepository _repository;

  Future<void> _carregar() async {
    try {
      final denuncias = await _repository.listar();
      emit(
        DenunciasLoaded(
          denuncias.map(DenunciaResumoViewModel.fromEntity).toList(),
        ),
      );
    } catch (e) {
      emit(DenunciasError(e.toString()));
    }
  }
}
