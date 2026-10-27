enum RecebimentoStatus { pendente, confirmado }

/// Um recebimento de insumo despachado para o aplicador — pendente de
/// confirmação de entrega ou já confirmado (ver [RecebimentoRepository]).
///
/// [confirmadoEm] é a data/hora em que o aplicador confirmou no app
/// (ocorrência); [registradoEm] é quando a confirmação chegou ao servidor.
/// Em confirmação offline os dois diferem, e [registradoEm] fica nulo até a
/// sincronização.
class Recebimento {
  final String id;
  final String produtoNome;
  final String lote;
  final String quantidadeDescricao;
  final String agenteEntregador;
  final String cargoAgenteEntregador;
  final DateTime dataDespacho;
  final RecebimentoStatus status;
  final DateTime? confirmadoEm;
  final DateTime? registradoEm;

  const Recebimento({
    required this.id,
    required this.produtoNome,
    required this.lote,
    required this.quantidadeDescricao,
    required this.agenteEntregador,
    required this.cargoAgenteEntregador,
    required this.dataDespacho,
    required this.status,
    this.confirmadoEm,
    this.registradoEm,
  });

  bool get pendenteSincronizacao =>
      status == RecebimentoStatus.confirmado && registradoEm == null;

  Recebimento copyWith({
    RecebimentoStatus? status,
    DateTime? confirmadoEm,
    DateTime? registradoEm,
  }) {
    return Recebimento(
      id: id,
      produtoNome: produtoNome,
      lote: lote,
      quantidadeDescricao: quantidadeDescricao,
      agenteEntregador: agenteEntregador,
      cargoAgenteEntregador: cargoAgenteEntregador,
      dataDespacho: dataDespacho,
      status: status ?? this.status,
      confirmadoEm: confirmadoEm ?? this.confirmadoEm,
      registradoEm: registradoEm ?? this.registradoEm,
    );
  }
}
