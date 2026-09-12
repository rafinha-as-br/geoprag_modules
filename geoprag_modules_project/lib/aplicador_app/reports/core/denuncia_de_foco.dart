/// Nível de infestação identificado no foco denunciado pelo aplicador.
enum NivelInfestacaoFoco { baixo, medio, alto }

/// Situação de atendimento de uma [DenunciaDeFoco].
enum StatusDenunciaDeFoco { recebida, atendida }

/// Uma denúncia de foco de infestação registrada em campo pelo aplicador,
/// exibida no seu próprio dashboard de denúncias.
class DenunciaDeFoco {
  final String id;
  final NivelInfestacaoFoco nivelInfestacao;
  final String localDescricao;
  final StatusDenunciaDeFoco status;
  final DateTime dataRegistro;
  final String? observacoes;

  const DenunciaDeFoco({
    required this.id,
    required this.nivelInfestacao,
    required this.localDescricao,
    required this.status,
    required this.dataRegistro,
    this.observacoes,
  });
}
