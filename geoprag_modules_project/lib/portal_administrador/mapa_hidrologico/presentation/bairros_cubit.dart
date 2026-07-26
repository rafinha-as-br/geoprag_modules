import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/corrego_repository.dart';
import 'bairro_view_model.dart';
import 'bairros_state.dart';

/// Carrega a listagem de Bairros monitorados (com status agregado dos seus
/// córregos) usada tanto no mapa geral quanto na tela de lista de bairros.
class BairrosCubit extends Cubit<BairrosState> {
  BairrosCubit(this._repository) : super(const BairrosLoading()) {
    _carregar();
  }

  final CorregoRepository _repository;

  Future<void> _carregar() async {
    try {
      final bairros = await _repository.listarBairros();
      emit(
        BairrosLoaded(bairros.map(BairroResumoViewModel.fromEntity).toList()),
      );
    } catch (e) {
      emit(BairrosError(e.toString()));
    }
  }
}
