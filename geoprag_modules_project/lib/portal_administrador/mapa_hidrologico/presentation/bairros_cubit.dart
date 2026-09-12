import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/corrego_repository.dart';
import 'bairro_view_model.dart';
import 'bairros_state.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

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
    } on EntidadeNaoEncontradaException catch (e) {
      emit(BairrosError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('BairrosCubit._carregar', e, stackTrace);
      emit(BairrosError(AppErrorMessages.carregamentoGenerico));
    }
  }
}
