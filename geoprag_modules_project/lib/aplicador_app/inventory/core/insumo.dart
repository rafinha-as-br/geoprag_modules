/// Um insumo (suprimento) controlado no estoque do aplicador — ex.: BTI
/// Líquido, BTI Sólido — exibido no card de "Estoque Atual" do inventário.
class Insumo {
  final String id;
  final String nome;
  final double quantidadeEmEstoque;
  final String unidadeMedida;
  final DateTime dataUltimaAtualizacao;

  const Insumo({
    required this.id,
    required this.nome,
    required this.quantidadeEmEstoque,
    required this.unidadeMedida,
    required this.dataUltimaAtualizacao,
  });
}
