import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../core/aplicador_ponto_de_aplicacao_repository.dart';
import 'detalhe_do_ponto_state.dart';
import 'detalhe_do_ponto_view_model.dart';

/// Carrega o ponto de aplicação designado ao aplicador para a tela de
/// detalhe.
class DetalheDoPontoDesignadoCubit extends Cubit<DetalheDoPontoDesignadoState> {
  DetalheDoPontoDesignadoCubit(this._repository, this._pontoId)
    : super(const DetalheDoPontoDesignadoLoading()) {
    _carregar();
  }

  final AplicadorPontoDeAplicacaoRepository _repository;
  final String _pontoId;

  Future<void> _carregar() async {
    try {
      final ponto = await _repository.buscarPorId(_pontoId);
      emit(
        DetalheDoPontoDesignadoLoaded(
          DetalheDoPontoDesignadoViewModel.fromEntity(ponto),
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emit(DetalheDoPontoDesignadoError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('DetalheDoPontoDesignadoCubit._carregar', e, stackTrace);
      emit(DetalheDoPontoDesignadoError(AppErrorMessages.carregamentoGenerico));
    }
  }
}
