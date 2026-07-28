import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/aplicacao_repository.dart';
import 'aplicacao_atual_state.dart';
import 'aplicacao_view_model.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

/// Carrega a aplicação em andamento do aplicador (`aplicadorId`) para a tela
/// de execução da aplicação.
///
/// TODO(GEOPRAG-24): hoje `AplicadorNavigator.toAplicacaoRegistrar()` não
/// carrega um id (ver `core/aplicador_navigator.dart`) — o `aplicadorId` é
/// passado pelo app consumidor ao montar este Cubit em `bootstrap.dart`;
/// falta o roteamento real repassar qual aplicador está autenticado/em
/// campo.
class AplicacaoAtualCubit extends Cubit<AplicacaoAtualState> {
  AplicacaoAtualCubit(this._repository, this._aplicadorId)
    : super(const AplicacaoAtualLoading()) {
    _carregar();
  }

  final AplicacaoRepository _repository;
  final String _aplicadorId;

  Future<void> _carregar() async {
    try {
      final aplicacao = await _repository.buscarAtual(_aplicadorId);
      emit(
        AplicacaoAtualLoaded(AplicacaoAtualViewModel.fromEntity(aplicacao)),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emit(AplicacaoAtualError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('AplicacaoAtualCubit._carregar', e, stackTrace);
      emit(AplicacaoAtualError(AppErrorMessages.carregamentoGenerico));
    }
  }
}
