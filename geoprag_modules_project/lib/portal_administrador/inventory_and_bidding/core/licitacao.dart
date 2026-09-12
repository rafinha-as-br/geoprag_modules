/// Um processo de licitação/edital homologado (GEOPRAG-105) — a fonte de
/// origem de todo [Produto] adquirido pelo Portal Administrador. O fornecedor
/// vencedor daqui é o mesmo repassado ao [Produto.fornecedor] vinculado.
class Licitacao {
  final String id;
  final String numeroAno; // ex.: 'Pregão 01/2026'
  final String fornecedorVencedor;
  final String objetoLicitado;
  final double valorTotal;
  final DateTime dataHomologacao;

  const Licitacao({
    required this.id,
    required this.numeroAno,
    required this.fornecedorVencedor,
    required this.objetoLicitado,
    required this.valorTotal,
    required this.dataHomologacao,
  });
}
