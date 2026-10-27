import 'aplicacao_de_campo_view_model.dart';

sealed class GeolocalizacaoState {
  const GeolocalizacaoState();
}

class GeolocalizacaoLoading extends GeolocalizacaoState {
  const GeolocalizacaoLoading();
}

/// Onde a verificação de chegada ao ponto está (GEOPRAG-191).
sealed class VerificacaoDeChegada {
  const VerificacaoDeChegada();
}

/// Lendo a posição do GPS.
class ChegadaVerificando extends VerificacaoDeChegada {
  const ChegadaVerificando();
}

/// Sem posição (permissão negada, GPS desligado ou tempo esgotado): o app não
/// deixa registrar e orienta com [mensagem]; o aplicador pode tentar de novo.
class ChegadaSemPosicao extends VerificacaoDeChegada {
  const ChegadaSemPosicao(this.mensagem);

  final String mensagem;
}

/// Fora do raio de chegada: o registro fica bloqueado.
class ChegadaForaDoRaio extends VerificacaoDeChegada {
  const ChegadaForaDoRaio(this.distanciaMetros);

  final double distanciaMetros;
}

/// Pode registrar. [distanciaMetros] é `null` na primeira aplicação do ponto,
/// que não tem validação de chegada.
class ChegadaConfirmada extends VerificacaoDeChegada {
  const ChegadaConfirmada({this.distanciaMetros});

  final double? distanciaMetros;
}

/// [verificacao] diz se o aplicador já pode iniciar a aplicação neste ponto.
class GeolocalizacaoLoaded extends GeolocalizacaoState {
  final PontoParaAplicacaoViewModel ponto;
  final VerificacaoDeChegada verificacao;

  const GeolocalizacaoLoaded({
    required this.ponto,
    this.verificacao = const ChegadaVerificando(),
  });

  /// O aplicador pode iniciar a aplicação.
  bool get dentroDoRaio => verificacao is ChegadaConfirmada;

  GeolocalizacaoLoaded copyWith({VerificacaoDeChegada? verificacao}) {
    return GeolocalizacaoLoaded(
      ponto: ponto,
      verificacao: verificacao ?? this.verificacao,
    );
  }
}

class GeolocalizacaoError extends GeolocalizacaoState {
  final String message;
  const GeolocalizacaoError(this.message);
}
