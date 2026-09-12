/// Um item do histórico de auditoria de uma [Denuncia] (criação, mudança de
/// status, atribuição de equipe) exibido na tela de análise/detalhe.
class HistoricoDenuncia {
  final String titulo;
  final String autor;
  final DateTime dataHora;
  final String status;

  const HistoricoDenuncia({
    required this.titulo,
    required this.autor,
    required this.dataHora,
    required this.status,
  });
}
