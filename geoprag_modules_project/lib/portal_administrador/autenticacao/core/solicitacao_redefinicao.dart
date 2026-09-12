enum StatusSolicitacaoRedefinicao { aguardando, autorizado, negado }

/// Solicitação de redefinição de senha de um Sub-Administrador pendente de
/// autorização do Administrador principal (ver [AdminRole.subAdministrador]
/// em `admin_account.dart`).
class SolicitacaoRedefinicao {
  final String id;
  final String nomeSolicitante;
  final String cargo;
  final StatusSolicitacaoRedefinicao status;

  const SolicitacaoRedefinicao({
    required this.id,
    required this.nomeSolicitante,
    required this.cargo,
    required this.status,
  });

  SolicitacaoRedefinicao copyWith({StatusSolicitacaoRedefinicao? status}) {
    return SolicitacaoRedefinicao(
      id: id,
      nomeSolicitante: nomeSolicitante,
      cargo: cargo,
      status: status ?? this.status,
    );
  }
}
