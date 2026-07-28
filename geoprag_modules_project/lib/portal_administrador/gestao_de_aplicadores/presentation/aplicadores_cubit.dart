import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/aplicador_repository.dart';
import 'aplicador_view_model.dart';
import 'aplicadores_state.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

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
    } on EntidadeNaoEncontradaException catch (e) {
      emit(AplicadoresError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('AplicadoresCubit._carregar', e, stackTrace);
      emit(AplicadoresError(AppErrorMessages.carregamentoGenerico));
    }
  }
}
