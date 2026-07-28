import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/recebimento_repository.dart';
import 'recebimento_view_model.dart';
import 'recebimentos_state.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

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
    } on EntidadeNaoEncontradaException catch (e) {
      emit(RecebimentosError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('RecebimentosCubit._carregar', e, stackTrace);
      emit(RecebimentosError(AppErrorMessages.carregamentoGenerico));
    }
  }
}
