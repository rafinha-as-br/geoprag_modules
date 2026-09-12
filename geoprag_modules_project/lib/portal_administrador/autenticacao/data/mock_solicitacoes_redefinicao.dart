import '../core/solicitacao_redefinicao.dart';

/// Solicitação usada para simular o painel de autorização do Administrador
/// principal enquanto o contrato real de endpoints não é validado com o
/// backend.
const mockSolicitacaoRedefinicaoPendente = SolicitacaoRedefinicao(
  id: 'sr1',
  nomeSolicitante: 'Célia Ramos',
  cargo: 'Sub-Administrador',
  status: StatusSolicitacaoRedefinicao.aguardando,
);
