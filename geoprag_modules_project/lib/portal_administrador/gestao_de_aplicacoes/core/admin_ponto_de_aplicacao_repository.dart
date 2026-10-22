import '../../../src/entities/atraso_de_aplicacao.dart';
import '../../../src/entities/ponto_de_aplicacao.dart';

/// Contrato de acesso aos Pontos de Aplicação pelo Portal Administrador.
///
/// Prefixo `Admin` porque `aplicador_app/aplicacoes` já expõe um
/// `AplicadorPontoDeAplicacaoRepository` — o do aplicador enxerga só os
/// pontos atribuídos a ele, este enxerga todos os pontos do município
/// (mesma convenção de `AdminNavigator`/`AdminAccount`).
///
/// As invariantes que todas essas ações precisam respeitar já vivem no
/// domínio, em [PontoDeAplicacao].
///
/// TODO(GEOPRAG-24): contrato real dos endpoints ainda não validado com o
/// backend.
abstract class AdminPontoDeAplicacaoRepository {
  Future<List<PontoDeAplicacao>> listar();

  Future<List<PontoDeAplicacao>> listarPorBairro(String bairro);

  /// Lança `EntidadeNaoEncontradaException` se o [id] não existir.
  Future<PontoDeAplicacao> buscarPorId(String id);

  /// Ativa o ciclo do ponto [id] com o [agendamento] informado. Lança
  /// `EntidadeNaoEncontradaException` se o [id] não existir, ou
  /// `OperacaoNaoPermitidaException` se o estado atual não permitir ativação
  /// (ver [PontoDeAplicacao.ativar]).
  Future<void> ativar(String id, Agendamento agendamento);

  /// Desativa o ponto [id]. Lança `EntidadeNaoEncontradaException` se o [id]
  /// não existir, ou `OperacaoNaoPermitidaException` se já estiver
  /// desativado (ver [PontoDeAplicacao.desativar]).
  Future<void> desativar(String id);

  /// Atribui o aplicador [aplicadorId] ao ponto [id]. Lança
  /// `EntidadeNaoEncontradaException` se o [id] não existir.
  Future<void> atribuirAplicador(String id, String aplicadorId);

  /// Remove o aplicador responsável do ponto [id]. Lança
  /// `EntidadeNaoEncontradaException` se o [id] não existir, ou
  /// `OperacaoNaoPermitidaException` se o ponto estiver ativo (ver
  /// [PontoDeAplicacao.desatribuirAplicador]).
  Future<void> desatribuirAplicador(String id);

  /// Devolve o ponto [id] ao estado em que estava antes da última
  /// desativação. Lança `EntidadeNaoEncontradaException` se o [id] não
  /// existir, ou `OperacaoNaoPermitidaException` se o ponto não estiver
  /// desativado (ver [PontoDeAplicacao.reativar]).
  Future<void> reativar(String id);

  /// Renomeia o ponto [id] — sempre permitido. Lança
  /// `EntidadeNaoEncontradaException` se o [id] não existir (ver
  /// [PontoDeAplicacao.editarNome]).
  Future<void> editarNome(String id, String novoNome);

  /// Altera só a tolerância de atraso do ponto [id], em dias — sempre
  /// permitido, mesmo com o cadastro travado. Lança
  /// `EntidadeNaoEncontradaException` se o [id] não existir, ou
  /// `OperacaoNaoPermitidaException` se [novaToleranciaDias] for menor que 1
  /// (ver [PontoDeAplicacao.editarTolerancia]). Emite evento de auditoria
  /// quando o valor muda.
  Future<void> editarTolerancia(String id, int novaToleranciaDias);

  /// Ids dos pontos que hoje estão em atraso (GEOPRAG-160), decididos
  /// exclusivamente pela regra de domínio compartilhada
  /// ([PontoDeAplicacao.estadoDeAtraso]) — a UI não recalcula atraso. Um
  /// alerta removido manualmente não conta.
  Future<Set<String>> idsDePontosEmAtraso();

  /// Remove o alerta de atraso do ponto [id] — só do atraso atual: se a
  /// próxima recorrência atrasar, o alerta volta. Emite evento de auditoria
  /// (quem removeu e quando). Lança `EntidadeNaoEncontradaException` se o [id]
  /// não existir, ou `OperacaoNaoPermitidaException` se o ponto não estiver
  /// em atraso. Nunca bloqueia nenhuma outra ação sobre o ponto.
  Future<void> removerAlertaDeAtraso(String id);

  /// Atualiza o cadastro completo do ponto [id]. Lança
  /// `EntidadeNaoEncontradaException` se o [id] não existir, ou
  /// `OperacaoNaoPermitidaException` se o cadastro estiver travado (ver
  /// [PontoDeAplicacao.editarCadastroCompleto]).
  Future<void> editarCadastroCompleto(
    String id, {
    required String nome,
    required String bairro,
    required String endereco,
    required String numeroReferencia,
    required String descricaoDoTrecho,
    required double larguraMetros,
    required double profundidadeMetros,
    required double velocidadeMetrosPorSegundo,
    required double dosagemMl,
    required double distanciaEntreSubpontosMetros,
    required int quantidadeDeSubpontos,
    required int toleranciaDias,
  });

  /// Encerra o ciclo vigente do ponto [id], levando-o a
  /// [EstadoPontoDeAplicacao.inativa]. Lança
  /// `EntidadeNaoEncontradaException` se o [id] não existir, ou
  /// `OperacaoNaoPermitidaException` se o ponto não estiver ativo (ver
  /// [PontoDeAplicacao.cancelarAplicacaoQuimica]).
  Future<void> cancelarAplicacaoQuimica(String id);

  /// Cadastra um ponto novo. Nasce em
  /// [EstadoPontoDeAplicacao.enderecada] quando [aplicadorId] é `null`, ou
  /// em [EstadoPontoDeAplicacao.direcionada] quando um responsável já é
  /// escolhido na criação — nunca em operação, e nunca com coordenada
  /// (georreferenciamento só acontece em campo). A [toleranciaDias] nasce no
  /// padrão ([toleranciaPadraoDeAtrasoEmDias]) quando não informada.
  Future<PontoDeAplicacao> criar({
    required String nome,
    required String bairro,
    required String endereco,
    required String numeroReferencia,
    required String descricaoDoTrecho,
    required double larguraMetros,
    required double profundidadeMetros,
    required double velocidadeMetrosPorSegundo,
    required double dosagemMl,
    required double distanciaEntreSubpontosMetros,
    required int quantidadeDeSubpontos,
    String? aplicadorId,
    int toleranciaDias = toleranciaPadraoDeAtrasoEmDias,
  });
}
