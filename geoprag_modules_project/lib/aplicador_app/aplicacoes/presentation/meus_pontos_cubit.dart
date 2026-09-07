import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_logger.dart';
import '../core/aplicador_ponto_de_aplicacao_repository.dart';
import 'meus_pontos_state.dart';
import 'meus_pontos_view_model.dart';

/// Carrega os pontos de aplicação atribuídos ao aplicador logado
/// (`aplicadorId`), ordenados por urgência.
///
/// TODO(GEOPRAG-24): `aplicadorId` é passado pelo app consumidor ao montar
/// este Cubit em `bootstrap.dart` — falta o roteamento real repassar qual
/// aplicador está autenticado (mesma limitação registrada em
/// `core/aplicador_navigator.dart`).
class MeusPontosCubit extends Cubit<MeusPontosState> {
  MeusPontosCubit(this._repository, this._aplicadorId)
    : super(const MeusPontosLoading()) {
    carregar();
  }

  final AplicadorPontoDeAplicacaoRepository _repository;
  final String _aplicadorId;

  Future<void> carregar() async {
    emit(const MeusPontosLoading());
    try {
      final pontos = await _repository.listarMeusPontos(_aplicadorId);
      final ordenados = [...pontos]
        ..sort(compararPontosDoAplicadorPorUrgencia);
      emit(
        MeusPontosLoaded(
          ordenados.map(PontoDoAplicadorResumoViewModel.fromEntity).toList(),
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('MeusPontosCubit.carregar', e, stackTrace);
      emit(MeusPontosError(AppErrorMessages.carregamentoGenerico));
    }
  }
}
