import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/aplicacao_mapa_repository.dart';
import 'aplicacao_mapa_state.dart';
import 'aplicacao_mapa_view_model.dart';

/// Carrega os dados de uma Aplicação específica (`aplicacaoId`) para exibição
/// na tela de visualização de aplicação do Mapa Hidrológico.
///
/// TODO(GEOPRAG-24): não há hoje, em `AdminNavigator`, uma rota dedicada de
/// "visualizar aplicação no mapa" nem forma de repassar um id (ver
/// `core/admin_navigator.dart`) — o `aplicacaoId` é passado pelo app
/// consumidor ao montar este Cubit em `bootstrap.dart`. Mesma limitação já
/// registrada em
/// `gestao_de_aplicadores/presentation/aplicador_detalhe_cubit.dart`.
class AplicacaoMapaCubit extends Cubit<AplicacaoMapaState> {
  AplicacaoMapaCubit(this._repository, this._aplicacaoId)
    : super(const AplicacaoMapaLoading()) {
    _carregar();
  }

  final AplicacaoMapaRepository _repository;
  final String _aplicacaoId;

  Future<void> _carregar() async {
    try {
      final aplicacao = await _repository.buscarPorId(_aplicacaoId);
      emit(AplicacaoMapaLoaded(AplicacaoMapaViewModel.fromEntity(aplicacao)));
    } catch (e) {
      emit(AplicacaoMapaError('Não foi possível carregar os dados. Tente novamente.'));
    }
  }
}
