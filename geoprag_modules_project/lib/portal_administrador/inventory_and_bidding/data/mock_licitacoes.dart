import '../core/licitacao.dart';

final List<Licitacao> mockLicitacoes = [
  Licitacao(
    id: 'l1',
    numeroAno: 'Pregão 01/2026',
    fornecedorVencedor: 'BioInsumos Ltda.',
    objetoLicitado: 'Aquisição de BTI (Bacillus thuringiensis israelensis)',
    valorTotal: 85000,
    dataHomologacao: DateTime(2026, 1, 20),
  ),
  Licitacao(
    id: 'l2',
    numeroAno: 'Pregão 02/2026',
    fornecedorVencedor: 'AgroQuímica Sul Ltda.',
    objetoLicitado: 'Aquisição de larvicida biológico',
    valorTotal: 42000,
    dataHomologacao: DateTime(2026, 4, 10),
  ),
];
