import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/aplicador_repository.dart';
import 'aplicador_detalhe_state.dart';
import 'aplicador_view_model.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

/// Carrega o perfil completo e o histórico de atuações de um Aplicador
/// específico (`aplicadorId`) para a tela de detalhe.
///
/// TODO(GEOPRAG-24): hoje `AdminNavigator.toAplicadorDetalhes()` não carrega
/// um id (ver `core/admin_navigator.dart`) — o `aplicadorId` é passado pelo
/// app consumidor ao montar este Cubit em `bootstrap.dart`; falta o
/// roteamento real repassar qual aplicador foi selecionado na listagem.
class AplicadorDetalheCubit extends Cubit<AplicadorDetalheState> {
  AplicadorDetalheCubit(this._repository, this._aplicadorId)
    : super(const AplicadorDetalheLoading()) {
    _carregar();
  }

  final AplicadorRepository _repository;
  final String _aplicadorId;

  Future<void> _carregar() async {
    try {
      final aplicador = await _repository.buscarPorId(_aplicadorId);
      final historico = await _repository.buscarHistorico(_aplicadorId);
      emit(
        AplicadorDetalheLoaded(
          AplicadorDetalhadoViewModel.fromEntity(aplicador, historico),
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emit(AplicadorDetalheError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('AplicadorDetalheCubit._carregar', e, stackTrace);
      emit(AplicadorDetalheError(AppErrorMessages.carregamentoGenerico));
    }
  }
}
