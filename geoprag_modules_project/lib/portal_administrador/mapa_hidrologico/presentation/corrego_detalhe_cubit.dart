import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/corrego_repository.dart';
import 'corrego_detalhe_state.dart';
import 'corrego_view_model.dart';

/// Carrega os dados completos de um Córrego específico (`corregoId`) para a
/// tela de visualização individual.
///
/// TODO(GEOPRAG-24): não há hoje, em `AdminNavigator`, uma rota dedicada de
/// "visualizar córrego" nem forma de repassar um id (ver
/// `core/admin_navigator.dart`) — o `corregoId` é passado pelo app
/// consumidor ao montar este Cubit em `bootstrap.dart`. Mesma limitação já
/// registrada em
/// `gestao_de_aplicadores/presentation/aplicador_detalhe_cubit.dart`.
class CorregoDetalheCubit extends Cubit<CorregoDetalheState> {
  CorregoDetalheCubit(this._repository, this._corregoId)
    : super(const CorregoDetalheLoading()) {
    _carregar();
  }

  final CorregoRepository _repository;
  final String _corregoId;

  Future<void> _carregar() async {
    try {
      final corrego = await _repository.buscarPorId(_corregoId);
      emit(CorregoDetalheLoaded(CorregoDetalhadoViewModel.fromEntity(corrego)));
    } catch (e) {
      emit(CorregoDetalheError(e.toString()));
    }
  }
}
