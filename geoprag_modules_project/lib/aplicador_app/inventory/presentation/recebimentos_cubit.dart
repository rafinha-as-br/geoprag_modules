import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/recebimento_repository.dart';
import 'recebimento_view_model.dart';
import 'recebimentos_state.dart';

/// Carrega a listagem de recebimentos pendentes de confirmação para o
/// aplicador (`RecebimentosScreen`).
class RecebimentosCubit extends Cubit<RecebimentosState> {
  RecebimentosCubit(this._repository) : super(const RecebimentosLoading()) {
    _carregar();
  }

  final RecebimentoRepository _repository;

  Future<void> _carregar() async {
    try {
      final pendentes = await _repository.listarPendentes();
      emit(
        RecebimentosLoaded(
          pendentes.map(RecebimentoResumoViewModel.fromEntity).toList(),
        ),
      );
    } catch (e) {
      emit(RecebimentosError(e.toString()));
    }
  }
}
