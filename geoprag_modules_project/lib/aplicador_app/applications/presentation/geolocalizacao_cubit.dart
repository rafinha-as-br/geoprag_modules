import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/aplicacao_repository.dart';
import 'aplicacao_view_model.dart';
import 'geolocalizacao_state.dart';

/// Carrega o ponto da aplicação em andamento do aplicador (`aplicadorId`) e
/// controla a validação de geofence (distância até o ponto) exibida na tela
/// de validação de chegada.
///
/// TODO(GEOPRAG-24): a validação de chegada é simulada via
/// [confirmarChegada] — falta integração real com GPS do dispositivo e
/// cálculo de distância contra o ponto cadastrado (ver módulo
/// `application_points`). O `aplicadorId` também é passado pelo app
/// consumidor ao montar este Cubit em `bootstrap.dart`, pelo mesmo motivo de
/// `AplicacaoAtualCubit` (ver `core/aplicador_navigator.dart`).
class GeolocalizacaoCubit extends Cubit<GeolocalizacaoState> {
  GeolocalizacaoCubit(this._repository, this._aplicadorId)
    : super(const GeolocalizacaoLoading()) {
    _carregar();
  }

  final AplicacaoRepository _repository;
  final String _aplicadorId;

  Future<void> _carregar() async {
    try {
      final aplicacao = await _repository.buscarAtual(_aplicadorId);
      emit(
        GeolocalizacaoLoaded(
          aplicacao: AplicacaoAtualViewModel.fromEntity(aplicacao),
        ),
      );
    } catch (e) {
      emit(GeolocalizacaoError('Não foi possível carregar os dados. Tente novamente.'));
    }
  }

  void confirmarChegada() {
    final atual = state;
    if (atual is GeolocalizacaoLoaded) {
      emit(atual.copyWith(dentroDoRaio: true));
    }
  }
}
