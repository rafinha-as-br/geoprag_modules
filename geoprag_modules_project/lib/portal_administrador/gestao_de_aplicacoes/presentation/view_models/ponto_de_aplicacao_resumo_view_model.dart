import '../../core/ponto_de_aplicacao.dart';

/// Dados de um ponto de aplicação para telas de listagem/mapa (dashboard e
/// visualização de bairro) — a tela nunca recebe [AdminPontoDeAplicacao] direto,
/// só os campos que ela de fato usa para desenhar um pin ou uma linha.
class PontoDeAplicacaoResumoViewModel {
  final String id;
  final String bairro;
  final double lat;
  final double lng;
  final StatusPontoDeAplicacao status;
  final bool ativo;

  const PontoDeAplicacaoResumoViewModel({
    required this.id,
    required this.bairro,
    required this.lat,
    required this.lng,
    required this.status,
    required this.ativo,
  });

  factory PontoDeAplicacaoResumoViewModel.fromEntity(AdminPontoDeAplicacao ponto) {
    return PontoDeAplicacaoResumoViewModel(
      id: ponto.id,
      bairro: ponto.bairro,
      lat: ponto.lat,
      lng: ponto.lng,
      status: ponto.status,
      ativo: ponto.ativo,
    );
  }
}
