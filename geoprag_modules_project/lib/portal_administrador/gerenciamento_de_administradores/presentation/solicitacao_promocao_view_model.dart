import '../core/solicitacao_promocao.dart';

/// ViewModel de [SolicitacaoPromocao] para a tela de Solicitações de
/// Promoção (GEOPRAG-36). Expõe só a contagem agregada de votos — sigilo do
/// voto individual, ver RN "Mecânica da Votação 2/3", regra específica 9.
class SolicitacaoPromocaoViewModel {
  final String id;
  final String subAdministradorEmail;
  final String subAdministradorNome;
  final String solicitanteEmail;
  final String solicitanteNome;
  final int votosFavoraveis;
  final int votosContrarios;
  final int limiar;
  final bool jaVotei;
  final bool souOSolicitante;

  const SolicitacaoPromocaoViewModel({
    required this.id,
    required this.subAdministradorEmail,
    required this.subAdministradorNome,
    required this.solicitanteEmail,
    required this.solicitanteNome,
    required this.votosFavoraveis,
    required this.votosContrarios,
    required this.limiar,
    required this.jaVotei,
    required this.souOSolicitante,
  });

  factory SolicitacaoPromocaoViewModel.fromEntity(
    SolicitacaoPromocao entity,
    String usuarioAtualEmail,
    Map<String, String> nomesPorEmail,
  ) {
    return SolicitacaoPromocaoViewModel(
      id: entity.id,
      subAdministradorEmail: entity.subAdministradorEmail,
      subAdministradorNome:
          nomesPorEmail[entity.subAdministradorEmail] ??
          entity.subAdministradorEmail,
      solicitanteEmail: entity.solicitanteEmail,
      solicitanteNome:
          nomesPorEmail[entity.solicitanteEmail] ?? entity.solicitanteEmail,
      votosFavoraveis: entity.votosFavoraveis,
      votosContrarios: entity.votosContrarios,
      limiar: entity.limiar,
      jaVotei: entity.votantesEmail.contains(usuarioAtualEmail),
      souOSolicitante: entity.solicitanteEmail == usuarioAtualEmail,
    );
  }
}
