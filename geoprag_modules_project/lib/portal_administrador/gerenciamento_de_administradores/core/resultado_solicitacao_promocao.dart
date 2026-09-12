import '../../autenticacao/core/admin_account.dart';
import 'solicitacao_promocao.dart';

/// Resultado de [AdministradorRepository.solicitarPromocao] — a base de
/// elegíveis pode estar travada em zero (nenhum "demais Administrador"
/// ativo), caso em que o sistema promove automaticamente sem abrir votação
/// (RN "Mecânica da Votação 2/3", regra específica 5).
sealed class ResultadoSolicitacaoPromocao {
  const ResultadoSolicitacaoPromocao();
}

class SolicitacaoPromocaoAberta extends ResultadoSolicitacaoPromocao {
  final SolicitacaoPromocao solicitacao;
  const SolicitacaoPromocaoAberta(this.solicitacao);
}

class PromocaoAutomatica extends ResultadoSolicitacaoPromocao {
  final AdminAccount conta;
  const PromocaoAutomatica(this.conta);
}
