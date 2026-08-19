/// Fórmula de conversão usada para calcular a dosagem de BTI aplicada em um
/// córrego a partir da vazão medida (Largura x Profundidade x Velocidade),
/// vinculada ao [Produto] do fabricante.
class FormulaDosagem {
  final String id;
  final String produtoId;
  final String produtoNome;
  final double fatorConversao;
  final double distanciaCarreamento;
  final double fatorCorrecao;
  final DateTime atualizadoEm;

  const FormulaDosagem({
    required this.id,
    required this.produtoId,
    required this.produtoNome,
    required this.fatorConversao,
    required this.distanciaCarreamento,
    required this.fatorCorrecao,
    required this.atualizadoEm,
  });
}
