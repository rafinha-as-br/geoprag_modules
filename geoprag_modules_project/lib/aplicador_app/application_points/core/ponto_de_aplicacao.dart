/// Ponto de aplicação atribuído ao aplicador logado no `aplicador_app`:
/// localização GPS do início do ponto mais o status do ciclo de
/// aplicações naquele ponto.
///
/// A mesma entidade é usada tanto para o perfil "atual" do ponto
/// ([PontoDeAplicacaoRepository.buscarAtual]) quanto para uma leitura de GPS
/// recém-capturada ao (re)marcar o ponto inicial
/// ([PontoDeAplicacaoRepository.capturarLocalizacaoAtual]).
class PontoDeAplicacao {
  final String id;
  final String nomePonto;
  final String referencia;
  final double latitude;
  final double longitude;
  final double precisaoMetros;
  final String status; // 'no_prazo' | 'atrasado'
  final DateTime dataUltimaAplicacao;
  final DateTime dataProximaAplicacaoEstimada;

  const PontoDeAplicacao({
    required this.id,
    required this.nomePonto,
    required this.referencia,
    required this.latitude,
    required this.longitude,
    required this.precisaoMetros,
    required this.status,
    required this.dataUltimaAplicacao,
    required this.dataProximaAplicacaoEstimada,
  });
}
