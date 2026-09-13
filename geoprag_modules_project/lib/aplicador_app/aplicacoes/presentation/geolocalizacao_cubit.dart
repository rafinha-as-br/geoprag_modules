import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../core/aplicador_ponto_de_aplicacao_repository.dart';
import 'aplicacao_de_campo_view_model.dart';
import 'geolocalizacao_state.dart';

/// Carrega o ponto de aplicação (`pontoId`) e controla a validação de
/// geofence (distância até o ponto) exibida na tela de validação de
/// chegada.
///
/// TODO(GEOPRAG-24): a validação de chegada é simulada via
/// [confirmarChegada] — falta integração real com GPS do dispositivo e
/// cálculo de distância contra o ponto cadastrado.
class GeolocalizacaoCubit extends Cubit<GeolocalizacaoState> {
  GeolocalizacaoCubit(this._repository, this._pontoId)
    : super(const GeolocalizacaoLoading()) {
    _carregar();
  }

  final AplicadorPontoDeAplicacaoRepository _repository;
  final String _pontoId;

  Future<void> _carregar() async {
    try {
      final ponto = await _repository.buscarPorId(_pontoId);
      emit(
        GeolocalizacaoLoaded(
          ponto: PontoParaAplicacaoViewModel.fromEntity(ponto),
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emit(GeolocalizacaoError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('GeolocalizacaoCubit._carregar', e, stackTrace);
      emit(GeolocalizacaoError(AppErrorMessages.carregamentoGenerico));
    }
  }

  void confirmarChegada() {
    final atual = state;
    if (atual is GeolocalizacaoLoaded) {
      emit(atual.copyWith(dentroDoRaio: true));
    }
  }
}
