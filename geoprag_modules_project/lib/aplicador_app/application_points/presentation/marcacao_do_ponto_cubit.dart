import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/ponto_de_aplicacao.dart';
import '../core/ponto_de_aplicacao_repository.dart';
import 'marcacao_do_ponto_state.dart';
import 'ponto_de_aplicacao_view_model.dart';

/// Captura a localização GPS do dispositivo e permite salvar o novo ponto
/// inicial do trecho, para a tela `MarcacaoDoPontoScreen`.
///
/// TODO(GEOPRAG-24): a captura de GPS hoje é simulada via
/// `PontoDeAplicacaoRepository.capturarLocalizacaoAtual`; falta integrar um
/// plugin real de geolocalização (ex.: `geolocator`) neste módulo.
class MarcacaoDoPontoCubit extends Cubit<MarcacaoDoPontoState> {
  MarcacaoDoPontoCubit(this._repository)
    : super(const MarcacaoDoPontoCapturando()) {
    _capturarLocalizacao();
  }

  final PontoDeAplicacaoRepository _repository;
  PontoDeAplicacao? _pontoCapturado;

  Future<void> _capturarLocalizacao() async {
    try {
      final ponto = await _repository.capturarLocalizacaoAtual();
      _pontoCapturado = ponto;
      emit(
        MarcacaoDoPontoCapturado(CapturaLocalizacaoViewModel.fromEntity(ponto)),
      );
    } catch (e) {
      emit(MarcacaoDoPontoErro('Não foi possível carregar os dados. Tente novamente.'));
    }
  }

  Future<void> salvar() async {
    final ponto = _pontoCapturado;
    final estadoAtual = state;
    if (ponto == null || estadoAtual is! MarcacaoDoPontoCapturado) return;

    emit(MarcacaoDoPontoCapturado(estadoAtual.captura, salvando: true));
    try {
      await _repository.marcarPontoInicial(ponto);
      emit(const MarcacaoDoPontoSalvo());
    } catch (e) {
      emit(MarcacaoDoPontoErro('Não foi possível carregar os dados. Tente novamente.'));
    }
  }
}
