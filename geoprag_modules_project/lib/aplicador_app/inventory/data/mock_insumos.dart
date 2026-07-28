import '../core/insumo.dart';

final List<Insumo> mockInsumos = [
  Insumo(
    id: '1',
    nome: 'BTI Líquido',
    quantidadeEmEstoque: 950,
    unidadeMedida: 'ml',
    dataUltimaAtualizacao: DateTime.now(),
  ),
  Insumo(
    id: '2',
    nome: 'BTI Sólido',
    quantidadeEmEstoque: 500,
    unidadeMedida: 'g',
    dataUltimaAtualizacao: DateTime.now().subtract(const Duration(days: 5)),
  ),
];
