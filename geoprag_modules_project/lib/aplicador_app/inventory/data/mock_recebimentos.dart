import '../core/recebimento.dart';

/// Simula a conectividade do app para o repositório mockado: `false` faz
/// `confirmar` ficar pendente de sincronização.
///
/// TODO(GEOPRAG-190): substituir por detecção real + fila offline.
bool mockRecebimentosOnline = true;

final List<Recebimento> mockRecebimentos = [
  Recebimento(
    id: 'r1',
    produtoNome: 'BTI Líquido',
    lote: 'L-2026-0145',
    quantidadeDescricao: '1 Litro',
    agenteEntregador: 'João Silva',
    cargoAgenteEntregador: 'Fiscal de Agricultura',
    dataDespacho: DateTime(2026, 7, 5, 14, 30),
    status: RecebimentoStatus.pendente,
  ),
  Recebimento(
    id: 'r2',
    produtoNome: 'BTI Sólido',
    lote: 'L-2026-0151',
    quantidadeDescricao: '500g',
    agenteEntregador: 'João Silva',
    cargoAgenteEntregador: 'Fiscal de Agricultura',
    dataDespacho: DateTime(2026, 7, 3, 9, 0),
    status: RecebimentoStatus.pendente,
  ),
];
