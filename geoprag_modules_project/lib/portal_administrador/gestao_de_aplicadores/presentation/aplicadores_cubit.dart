import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/aplicador_repository.dart';
import 'aplicador_view_model.dart';
import 'aplicadores_state.dart';

/// Carrega a listagem de Aplicadores cadastrados para o dashboard.
class AplicadoresCubit extends Cubit<AplicadoresState> {
  AplicadoresCubit(this._repository) : super(const AplicadoresLoading()) {
    _carregar();
  }

  final AplicadorRepository _repository;

  Future<void> _carregar() async {
    try {
      final aplicadores = await _repository.listar();
      emit(
        AplicadoresLoaded(
          aplicadores.map(AplicadorResumoViewModel.fromEntity).toList(),
        ),
      );
    } catch (e) {
      emit(AplicadoresError(e.toString()));
    }
  }
}
