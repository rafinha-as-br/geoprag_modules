import '../core/solicitacao_redefinicao.dart';

/// ViewModel principal de [SolicitacaoRedefinicao] para a tela de
/// autorização — só os campos que a tela efetivamente exibe.
class SolicitacaoRedefinicaoViewModel {
  final String nomeSolicitante;
  final String cargo;
  final StatusSolicitacaoRedefinicao status;

  const SolicitacaoRedefinicaoViewModel({
    required this.nomeSolicitante,
    required this.cargo,
    required this.status,
  });

  factory SolicitacaoRedefinicaoViewModel.fromEntity(
    SolicitacaoRedefinicao entity,
  ) {
    return SolicitacaoRedefinicaoViewModel(
      nomeSolicitante: entity.nomeSolicitante,
      cargo: entity.cargo,
      status: entity.status,
    );
  }
}
