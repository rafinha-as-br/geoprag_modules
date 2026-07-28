import '../core/formula_dosagem.dart';

final List<FormulaDosagem> mockFormulasDosagem = [
  FormulaDosagem(
    id: 'f1',
    produtoId: 'p1',
    produtoNome: 'BTI Líquido',
    fatorConversao: 1.5,
    distanciaCarreamento: 150,
    fatorCorrecao: 1.2,
    atualizadoEm: DateTime(2026, 6, 1),
  ),
  FormulaDosagem(
    id: 'f2',
    produtoId: 'p2',
    produtoNome: 'BTI Granulado',
    fatorConversao: 2.0,
    distanciaCarreamento: 100,
    fatorCorrecao: 1.1,
    atualizadoEm: DateTime(2026, 5, 15),
  ),
];
