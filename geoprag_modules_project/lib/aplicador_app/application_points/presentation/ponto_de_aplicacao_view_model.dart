import '../core/ponto_de_aplicacao.dart';

/// Formata uma data como `dd/MM/yyyy` (sem dependência de `intl`, seguindo o
/// padrão já usado neste pacote para formatação manual — ver
/// `GeopragCountdown`).
String _formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}

/// ViewModel do ponto de aplicação atual — usada na tela de visão geral do
/// aplicador (`VisualizacaoDoPontoScreen`).
class PontoDeAplicacaoViewModel {
  final String nomePonto;
  final String referencia;
  final bool estaNoPrazo;
  final DateTime dataUltimaAplicacao;
  final DateTime dataProximaAplicacaoEstimada;

  const PontoDeAplicacaoViewModel({
    required this.nomePonto,
    required this.referencia,
    required this.estaNoPrazo,
    required this.dataUltimaAplicacao,
    required this.dataProximaAplicacaoEstimada,
  });

  String get dataUltimaAplicacaoFormatada =>
      _formatarData(dataUltimaAplicacao);

  String get dataProximaAplicacaoEstimadaFormatada =>
      _formatarData(dataProximaAplicacaoEstimada);

  factory PontoDeAplicacaoViewModel.fromEntity(PontoDeAplicacao entity) {
    return PontoDeAplicacaoViewModel(
      nomePonto: entity.nomePonto,
      referencia: entity.referencia,
      estaNoPrazo: entity.status == 'no_prazo',
      dataUltimaAplicacao: entity.dataUltimaAplicacao,
      dataProximaAplicacaoEstimada: entity.dataProximaAplicacaoEstimada,
    );
  }
}

/// ViewModel da leitura de GPS capturada ao (re)marcar a localização
/// inicial do ponto de aplicação (`MarcacaoDoPontoScreen`).
class CapturaLocalizacaoViewModel {
  final double latitude;
  final double longitude;
  final double precisaoMetros;

  const CapturaLocalizacaoViewModel({
    required this.latitude,
    required this.longitude,
    required this.precisaoMetros,
  });

  /// Classificação textual da precisão do GPS: Alta (< 10m), Média (< 30m)
  /// ou Baixa.
  String get qualidadePrecisao {
    if (precisaoMetros < 10) return 'Alta';
    if (precisaoMetros < 30) return 'Média';
    return 'Baixa';
  }

  String get coordenadasFormatadas =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  factory CapturaLocalizacaoViewModel.fromEntity(PontoDeAplicacao entity) {
    return CapturaLocalizacaoViewModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      precisaoMetros: entity.precisaoMetros,
    );
  }
}
