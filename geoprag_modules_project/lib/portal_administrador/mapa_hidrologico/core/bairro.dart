/// Um bairro monitorado do município, agregando o status de aplicação dos
/// [Corrego]s que o atravessam.
///
/// Mantido deliberadamente enxuto (ver guia de arquitetura): apenas os ids
/// dos córregos do bairro, e não uma composição aninhada com o objeto
/// [Corrego] completo — quem precisa dos córregos do bairro busca via
/// `CorregoRepository.listarCorregosDoBairro`.
class Bairro {
  final String id;
  final String nome;
  final String status; // 'em_dia' | 'atrasado' | 'denuncia'
  final int diasSemAplicacao;
  final List<String> corregoIds;

  const Bairro({
    required this.id,
    required this.nome,
    required this.status,
    required this.diasSemAplicacao,
    required this.corregoIds,
  });
}
