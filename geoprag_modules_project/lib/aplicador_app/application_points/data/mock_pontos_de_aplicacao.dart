import '../core/ponto_de_aplicacao.dart';

/// Ponto de aplicação atualmente atribuído ao aplicador logado.
///
/// TODO(GEOPRAG-24): o app hoje assume um único aplicador/ponto de
/// aplicação logado;
/// falta o backend expor "meu ponto atual" por sessão autenticada.
final PontoDeAplicacao mockPontoDeAplicacaoAtual = PontoDeAplicacao(
  id: '1',
  nomePonto: 'Córrego Gasparinho - Ponto 01',
  referencia: 'Rua Pedro Simon, Margem Esquerda',
  latitude: -26.9312,
  longitude: -48.9567,
  precisaoMetros: 4,
  status: 'no_prazo',
  dataUltimaAplicacao: DateTime(2026, 5, 10),
  dataProximaAplicacaoEstimada: DateTime(2026, 5, 25),
);

/// Leitura simulada de GPS usada ao (re)marcar a localização inicial do
/// ponto de aplicação em [mockPontoDeAplicacaoAtual].
///
/// TODO(GEOPRAG-24): substituir pela leitura real de um plugin de
/// geolocalização (ex.: `geolocator`) quando o hardware for integrado.
final PontoDeAplicacao mockCapturaLocalizacaoAtual = PontoDeAplicacao(
  id: mockPontoDeAplicacaoAtual.id,
  nomePonto: mockPontoDeAplicacaoAtual.nomePonto,
  referencia: mockPontoDeAplicacaoAtual.referencia,
  latitude: -26.9312,
  longitude: -48.9567,
  precisaoMetros: 4,
  status: mockPontoDeAplicacaoAtual.status,
  dataUltimaAplicacao: mockPontoDeAplicacaoAtual.dataUltimaAplicacao,
  dataProximaAplicacaoEstimada:
      mockPontoDeAplicacaoAtual.dataProximaAplicacaoEstimada,
);
