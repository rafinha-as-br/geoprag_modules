import '../core/recebimento.dart';

final List<Recebimento> mockRecebimentos = [
  Recebimento(
    id: 'r1',
    produtoNome: 'BTI Líquido',
    quantidadeDescricao: '1 Litro',
    agenteEntregador: 'João Silva',
    cargoAgenteEntregador: 'Fiscal de Agricultura',
    dataDespacho: DateTime(2026, 7, 5, 14, 30),
    status: RecebimentoStatus.pendente,
  ),
  Recebimento(
    id: 'r2',
    produtoNome: 'BTI Sólido',
    quantidadeDescricao: '500g',
    agenteEntregador: 'João Silva',
    cargoAgenteEntregador: 'Fiscal de Agricultura',
    dataDespacho: DateTime(2026, 7, 3, 9, 0),
    status: RecebimentoStatus.pendente,
  ),
];
