import '../../core/ponto_de_aplicacao.dart';

/// Dados de um ponto de aplicação para a tela de detalhe/ações — inclui o
/// nome do aplicador já resolvido (não só o id) e flags de ação computadas,
/// para que a tela não precise decidir regra de negócio sozinha.
class PontoDeAplicacaoDetalheViewModel {
  final String id;
  final String bairro;
  final double lat;
  final double lng;
  final StatusPontoDeAplicacao status;
  final bool ativo;
  final String? aplicadorId;
  final String? nomeDoAplicador;
  final DateTime? dataAgendada;
  final DateTime? dataConcluida;
  final bool podeAtribuirAplicador;
  final bool podeDesativar;

  const PontoDeAplicacaoDetalheViewModel({
    required this.id,
    required this.bairro,
    required this.lat,
    required this.lng,
    required this.status,
    required this.ativo,
    this.aplicadorId,
    this.nomeDoAplicador,
    this.dataAgendada,
    this.dataConcluida,
    required this.podeAtribuirAplicador,
    required this.podeDesativar,
  });

  factory PontoDeAplicacaoDetalheViewModel.fromEntity(
    AdminPontoDeAplicacao ponto, {
    String? nomeDoAplicador,
  }) {
    return PontoDeAplicacaoDetalheViewModel(
      id: ponto.id,
      bairro: ponto.bairro,
      lat: ponto.lat,
      lng: ponto.lng,
      status: ponto.status,
      ativo: ponto.ativo,
      aplicadorId: ponto.aplicadorId,
      nomeDoAplicador: nomeDoAplicador,
      dataAgendada: ponto.dataAgendada,
      dataConcluida: ponto.dataConcluida,
      // Só faz sentido (des)atribuir/desativar um ponto ainda ativo; um
      // ponto desativado é editado (reativação) por outro fluxo.
      podeAtribuirAplicador: ponto.ativo,
      podeDesativar: ponto.ativo,
    );
  }
}
