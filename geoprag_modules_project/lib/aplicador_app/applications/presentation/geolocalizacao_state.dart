import 'aplicacao_view_model.dart';

sealed class GeolocalizacaoState {
  const GeolocalizacaoState();
}

class GeolocalizacaoLoading extends GeolocalizacaoState {
  const GeolocalizacaoLoading();
}

/// [dentroDoRaio] indica se o aplicador está dentro do raio de cobertura
/// permitido do ponto de aplicação — ver [GeolocalizacaoCubit.confirmarChegada].
class GeolocalizacaoLoaded extends GeolocalizacaoState {
  final AplicacaoAtualViewModel aplicacao;
  final bool dentroDoRaio;

  const GeolocalizacaoLoaded({
    required this.aplicacao,
    this.dentroDoRaio = false,
  });

  GeolocalizacaoLoaded copyWith({bool? dentroDoRaio}) {
    return GeolocalizacaoLoaded(
      aplicacao: aplicacao,
      dentroDoRaio: dentroDoRaio ?? this.dentroDoRaio,
    );
  }
}

class GeolocalizacaoError extends GeolocalizacaoState {
  final String message;
  const GeolocalizacaoError(this.message);
}
