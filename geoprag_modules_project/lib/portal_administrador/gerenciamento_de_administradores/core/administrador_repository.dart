import '../../autenticacao/core/admin_account.dart';
import 'resultado_solicitacao_promocao.dart';
import 'solicitacao_promocao.dart';

/// Contrato de acesso e gerenciamento dos usuários administradores do Portal
/// Administrador (GEOPRAG-36). Todo cadastro novo nasce como
/// [AdminRole.subAdministrador] — não existe seleção de cargo no formulário
/// de criação; a elevação a [AdminRole.administrador] só ocorre por
/// promoção, ver [solicitarPromocao]/[votar] e a RN "Promoção e
/// Rebaixamento de Cargo de Administrador".
///
/// TODO(GEOPRAG-36): validação de permissão (403 se quem chama não tiver
/// cargo Administrador) é responsabilidade do backend — não há repositório
/// `geoprag_api` conectado nesta sessão de trabalho para implementar aqui.
abstract class AdministradorRepository {
  Future<AdminAccount> criar({
    required String email,
    required String nome,
    required String cpf,
    required DateTime dataNascimento,
    required String sexo,
  });

  Future<List<AdminAccount>> listar();

  /// Desativa o cadastro de [email]. Só um Administrador ativo pode acionar
  /// (ver RN "Cadastro e Acesso do Administrador e Sub-Administrador",
  /// seção 4, regra 4). Se o alvo for Sub-Administrador com votação de
  /// promoção em aberto, a votação é cancelada automaticamente (RN
  /// "Mecânica da Votação 2/3", regra específica 7).
  Future<void> desativar({
    required String email,
    required String executorEmail,
  });

  /// Reativa o cadastro de [email], previamente desativado. Só um
  /// Administrador ativo pode acionar. A data da última desativação
  /// (`dataDesativacao`) não é apagada — só o `status` volta a `ativo`.
  Future<void> reativar({required String email, required String executorEmail});

  /// Rebaixa [email] (Administrador) a Sub-Administrador. Ação unilateral,
  /// sem votação — só um Administrador ativo diferente do alvo pode acionar
  /// (RN "Promoção e Rebaixamento de Cargo de Administrador", seção 3.2 e
  /// regra específica 3). Como o executor precisa ser um Administrador
  /// ativo distinto do alvo, esta operação nunca deixa o sistema sem
  /// nenhum Administrador ativo diretamente — o desenho de uma trava mais
  /// ampla contra outros cenários ainda está pendente (GEOPRAG-53).
  Future<void> rebaixar({required String email, required String executorEmail});

  /// Abre uma votação de promoção para [subAdministradorEmail], iniciada
  /// por [solicitanteEmail]. Se não houver nenhum outro Administrador ativo
  /// elegível a votar, promove automaticamente sem abrir votação (RN
  /// "Mecânica da Votação 2/3", regra específica 5).
  Future<ResultadoSolicitacaoPromocao> solicitarPromocao({
    required String solicitanteEmail,
    required String subAdministradorEmail,
  });

  Future<List<SolicitacaoPromocao>> listarSolicitacoesAbertas();

  /// Registra o voto de [votanteEmail] na solicitação [solicitacaoId]. Voto
  /// é definitivo (não pode ser repetido) e a votação é encerrada
  /// automaticamente assim que um dos limiares de 2/3 é atingido.
  Future<void> votar({
    required String solicitacaoId,
    required String votanteEmail,
    required bool aprovar,
  });

  /// Cancela manualmente a solicitação [solicitacaoId]. Só permitido a
  /// [solicitanteEmail] enquanto ele mantiver o cargo de Administrador
  /// ativo (RN "Mecânica da Votação 2/3", regra específica 6).
  Future<void> cancelarSolicitacao({
    required String solicitacaoId,
    required String solicitanteEmail,
  });
}
