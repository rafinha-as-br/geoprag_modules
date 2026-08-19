enum AtuacaoAplicadorTipo { aplicacao, recebimento }

/// Um item do histórico de atuações de um [Aplicador] (aplicação realizada
/// ou recebimento de insumo confirmado) exibido na tela de detalhe.
class AtuacaoAplicador {
  final AtuacaoAplicadorTipo tipo;
  final String titulo;
  final String subtitulo;
  final String valor;

  const AtuacaoAplicador({
    required this.tipo,
    required this.titulo,
    required this.subtitulo,
    required this.valor,
  });
}
