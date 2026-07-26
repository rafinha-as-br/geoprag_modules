import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/resumo_geral_repository.dart';
import 'dashboard_geral_state.dart';
import 'resumo_geral_view_model.dart';

/// Carrega o resumo geral operacional exibido no Dashboard do Portal
/// Administrador.
class DashboardGeralCubit extends Cubit<DashboardGeralState> {
  DashboardGeralCubit(this._repository)
    : super(const DashboardGeralLoading()) {
    _carregar();
  }

  final ResumoGeralRepository _repository;

  Future<void> _carregar() async {
    try {
      final resumo = await _repository.buscar();
      emit(DashboardGeralLoaded(ResumoGeralViewModel.fromEntity(resumo)));
    } catch (e) {
      emit(DashboardGeralError(e.toString()));
    }
  }
}
