/// Uma denúncia de foco de infestação registrada por um morador ou
/// voluntário, encaminhada para triagem e tratamento pela equipe do Portal
/// Administrador.
class Denuncia {
  final String id;
  final double lat;
  final double lng;
  final String nivelInfestacao;
  final String descricao;
  final String status;
  final DateTime dataHora;
  final String denunciante;
  final String observacoes;

  const Denuncia({
    required this.id,
    required this.lat,
    required this.lng,
    required this.nivelInfestacao,
    required this.descricao,
    required this.status,
    required this.dataHora,
    required this.denunciante,
    required this.observacoes,
  });
}
