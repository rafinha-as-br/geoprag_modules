/// Estado de uma solicitação de promoção de Sub-Administrador a
/// Administrador (GEOPRAG-36), conforme "Regra de Negócio - Promoção e
/// Rebaixamento de Cargo de Administrador", seção 3.1.
enum StatusSolicitacaoPromocao { aberta, aprovada, reprovada, cancelada }

/// Votação de 2/3 para promover um Sub-Administrador a Administrador. Ver
/// "Regra de Negócio - Mecânica da Votação 2/3 na Promoção de
/// Administrador" para o detalhamento completo de cada regra abaixo.
class SolicitacaoPromocao {
  final String id;
  final String subAdministradorEmail;
  final String solicitanteEmail;
  final DateTime dataAbertura;

  /// Base de Administradores elegíveis travada no momento da abertura
  /// (denominador do cálculo de 2/3) — não muda com promoções/rebaixamentos
  /// posteriores à abertura desta votação.
  final int baseElegiveisTravada;

  /// Quem já votou nesta solicitação — voto é definitivo, não pode ser
  /// alterado enquanto a votação estiver aberta.
  final Set<String> votantesEmail;

  final int votosFavoraveis;
  final int votosContrarios;
  final StatusSolicitacaoPromocao status;

  const SolicitacaoPromocao({
    required this.id,
    required this.subAdministradorEmail,
    required this.solicitanteEmail,
    required this.dataAbertura,
    required this.baseElegiveisTravada,
    required this.votantesEmail,
    required this.votosFavoraveis,
    required this.votosContrarios,
    required this.status,
  });

  /// Limiar de votos necessário para aprovar ou reprovar: 2/3 da base
  /// travada, arredondado para cima quando não for um número inteiro.
  int get limiar => (baseElegiveisTravada * 2 / 3).ceil();

  bool get aberta => status == StatusSolicitacaoPromocao.aberta;

  SolicitacaoPromocao copyWith({
    Set<String>? votantesEmail,
    int? votosFavoraveis,
    int? votosContrarios,
    StatusSolicitacaoPromocao? status,
  }) => SolicitacaoPromocao(
    id: id,
    subAdministradorEmail: subAdministradorEmail,
    solicitanteEmail: solicitanteEmail,
    dataAbertura: dataAbertura,
    baseElegiveisTravada: baseElegiveisTravada,
    votantesEmail: votantesEmail ?? this.votantesEmail,
    votosFavoraveis: votosFavoraveis ?? this.votosFavoraveis,
    votosContrarios: votosContrarios ?? this.votosContrarios,
    status: status ?? this.status,
  );
}
