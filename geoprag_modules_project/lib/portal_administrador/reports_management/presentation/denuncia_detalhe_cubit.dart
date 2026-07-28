import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/denuncia_repository.dart';
import 'denuncia_detalhe_state.dart';
import 'denuncia_view_model.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

/// Carrega os dados completos e o histórico de auditoria de uma Denúncia
/// específica (`denunciaId`) para a tela de análise/detalhe.
///
/// TODO(GEOPRAG-24): hoje `AdminNavigator.toDenunciaAdminDetalhes()` não
/// carrega um id (ver `core/admin_navigator.dart`) — o `denunciaId` é
/// passado pelo app consumidor ao montar este Cubit em `bootstrap.dart`;
/// falta o roteamento real repassar qual denúncia foi selecionada na
/// listagem.
class DenunciaDetalheCubit extends Cubit<DenunciaDetalheState> {
  DenunciaDetalheCubit(this._repository, this._denunciaId)
    : super(const DenunciaDetalheLoading()) {
    _carregar();
  }

  final DenunciaRepository _repository;
  final String _denunciaId;

  Future<void> _carregar() async {
    try {
      final denuncia = await _repository.buscarPorId(_denunciaId);
      final historico = await _repository.buscarHistorico(_denunciaId);
      emit(
        DenunciaDetalheLoaded(
          DenunciaDetalhadaViewModel.fromEntity(denuncia, historico),
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emit(DenunciaDetalheError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('DenunciaDetalheCubit._carregar', e, stackTrace);
      emit(DenunciaDetalheError(AppErrorMessages.carregamentoGenerico));
    }
  }
}
