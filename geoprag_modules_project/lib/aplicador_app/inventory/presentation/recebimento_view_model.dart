import '../core/recebimento.dart';

/// ViewModel resumida de [Recebimento] — usada na listagem de recebimentos
/// pendentes (`RecebimentosScreen`).
class RecebimentoResumoViewModel {
  final String id;
  final String produtoNome;
  final String quantidadeDescricao;
  final String enviadoPorDescricao;
  final String dataDescricao;

  const RecebimentoResumoViewModel({
    required this.id,
    required this.produtoNome,
    required this.quantidadeDescricao,
    required this.enviadoPorDescricao,
    required this.dataDescricao,
  });

  factory RecebimentoResumoViewModel.fromEntity(Recebimento entity) {
    return RecebimentoResumoViewModel(
      id: entity.id,
      produtoNome: entity.produtoNome,
      quantidadeDescricao: entity.quantidadeDescricao,
      enviadoPorDescricao:
          'Enviado por: ${entity.agenteEntregador} '
          '(${entity.cargoAgenteEntregador})',
      dataDescricao: 'Data: ${_formatarDataCurta(entity.dataDespacho)}',
    );
  }

  String get tituloProduto => '$produtoNome - $quantidadeDescricao';
}

/// ViewModel detalhada de [Recebimento] — dados completos exibidos na tela
/// de confirmação de recebimento (`ReceberProdutoScreen`).
class RecebimentoDetalheViewModel {
  final String id;
  final String produtoNome;
  final String quantidadeDescricao;
  final String agenteEntregadorDescricao;
  final String dataDespachoDescricao;

  const RecebimentoDetalheViewModel({
    required this.id,
    required this.produtoNome,
    required this.quantidadeDescricao,
    required this.agenteEntregadorDescricao,
    required this.dataDespachoDescricao,
  });

  factory RecebimentoDetalheViewModel.fromEntity(Recebimento entity) {
    return RecebimentoDetalheViewModel(
      id: entity.id,
      produtoNome: entity.produtoNome,
      quantidadeDescricao: entity.quantidadeDescricao,
      agenteEntregadorDescricao:
          '${entity.agenteEntregador} (${entity.cargoAgenteEntregador})',
      dataDespachoDescricao: _formatarDataHora(entity.dataDespacho),
    );
  }

  String get tituloProduto => '$produtoNome - $quantidadeDescricao';
}

String _formatarDataCurta(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}

String _formatarDataHora(DateTime data) {
  final hora = data.hour.toString().padLeft(2, '0');
  final minuto = data.minute.toString().padLeft(2, '0');
  return '${_formatarDataCurta(data)} às $hora:$minuto';
}
