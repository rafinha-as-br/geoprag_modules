import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/resumo_geral_repository.dart';
import 'dashboard_geral_state.dart';
import 'resumo_geral_view_model.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

/// Carrega o resumo geral operacional exibido no Dashboard do Portal
/// Administrador.
class DashboardGeralCubit extends Cubit<DashboardGeralState> {
  DashboardGeralCubit(this._repository) : super(const DashboardGeralLoading()) {
    _carregar();
  }

  final ResumoGeralRepository _repository;

  Future<void> _carregar() async {
    try {
      final resumo = await _repository.buscar();
      emit(DashboardGeralLoaded(ResumoGeralViewModel.fromEntity(resumo)));
    } on EntidadeNaoEncontradaException catch (e) {
      emit(DashboardGeralError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('DashboardGeralCubit._carregar', e, stackTrace);
      emit(DashboardGeralError(AppErrorMessages.carregamentoGenerico));
    }
  }
}
