class Produto {
  final String id;
  final String nome;
  final String lote;
  final DateTime dataValidade;
  final String status;
  final int quantidade;
  final int quantidadeOriginal;
  final String unidadeMedida;
  final String licitacao;
  final String fornecedor;

  const Produto({
    required this.id,
    required this.nome,
    required this.lote,
    required this.dataValidade,
    required this.status,
    required this.quantidade,
    required this.quantidadeOriginal,
    required this.unidadeMedida,
    required this.licitacao,
    required this.fornecedor,
  });
}
