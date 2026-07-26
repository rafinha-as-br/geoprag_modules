import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/ponto_de_aplicacao_repository.dart';
import 'ponto_de_aplicacao_state.dart';
import 'ponto_de_aplicacao_view_model.dart';

/// Carrega o ponto de aplicação atualmente atribuído ao aplicador logado
/// para a tela de visão geral (`VisualizacaoDoPontoScreen`).
///
/// TODO(GEOPRAG-24): hoje não há sessão/roteamento real no `aplicador_app` —
/// o repositório resolve "o ponto atual" a partir de um mock fixo; falta o
/// backend expor qual trecho pertence ao aplicador autenticado.
class PontoDeAplicacaoCubit extends Cubit<PontoDeAplicacaoState> {
  PontoDeAplicacaoCubit(this._repository)
    : super(const PontoDeAplicacaoLoading()) {
    _carregar();
  }

  final PontoDeAplicacaoRepository _repository;

  Future<void> _carregar() async {
    try {
      final ponto = await _repository.buscarAtual();
      emit(PontoDeAplicacaoLoaded(PontoDeAplicacaoViewModel.fromEntity(ponto)));
    } catch (e) {
      emit(PontoDeAplicacaoError(e.toString()));
    }
  }
}
