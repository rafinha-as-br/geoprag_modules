import 'ponto_de_aplicacao.dart';

/// Contrato de acesso ao ponto de aplicação atribuído ao aplicador logado
/// no `aplicador_app`.
///
/// TODO(GEOPRAG-24): contrato real dos endpoints ainda não validado com o
/// backend.
abstract class PontoDeAplicacaoRepository {
  /// Ponto de aplicação atualmente atribuído ao aplicador, com o status do
  /// ciclo de aplicações (usado em `VisualizacaoDoPontoScreen`).
  Future<PontoDeAplicacao> buscarAtual();

  /// Captura a localização GPS atual do dispositivo para (re)marcar a
  /// localização inicial do ponto de aplicação (usado em
  /// `MarcacaoDoPontoScreen`).
  ///
  /// TODO(GEOPRAG-24): hoje simulado; falta integrar com um plugin real de
  /// geolocalização (ex.: `geolocator`) neste módulo.
  Future<PontoDeAplicacao> capturarLocalizacaoAtual();

  /// Envia o ponto (re)marcado para validação da prefeitura.
  Future<void> marcarPontoInicial(PontoDeAplicacao ponto);
}
