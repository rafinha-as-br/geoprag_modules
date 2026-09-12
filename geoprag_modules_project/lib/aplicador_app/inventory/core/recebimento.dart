enum RecebimentoStatus { pendente, confirmado }

/// Um recebimento de insumo despachado para o aplicador — pendente de
/// confirmação de entrega ou já confirmado (ver [RecebimentoRepository]).
class Recebimento {
  final String id;
  final String produtoNome;
  final String quantidadeDescricao;
  final String agenteEntregador;
  final String cargoAgenteEntregador;
  final DateTime dataDespacho;
  final RecebimentoStatus status;

  const Recebimento({
    required this.id,
    required this.produtoNome,
    required this.quantidadeDescricao,
    required this.agenteEntregador,
    required this.cargoAgenteEntregador,
    required this.dataDespacho,
    required this.status,
  });

  Recebimento copyWith({RecebimentoStatus? status}) {
    return Recebimento(
      id: id,
      produtoNome: produtoNome,
      quantidadeDescricao: quantidadeDescricao,
      agenteEntregador: agenteEntregador,
      cargoAgenteEntregador: cargoAgenteEntregador,
      dataDespacho: dataDespacho,
      status: status ?? this.status,
    );
  }
}
