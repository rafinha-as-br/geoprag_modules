import '../../../src/entities/ponto_de_aplicacao.dart';

/// Contrato de acesso aos pontos de aplicação atribuídos ao aplicador
/// logado no `aplicador_app` — visão restrita (só os seus pontos), em
/// contraste com `AdminPontoDeAplicacaoRepository` (visão de todos os
/// pontos do município). Mesma convenção de prefixo de
/// `AdminNavigator`/`AdminAccount`.
///
/// TODO(GEOPRAG-24): contrato real dos endpoints ainda não validado com o
/// backend.
abstract class AplicadorPontoDeAplicacaoRepository {
  /// Pontos atribuídos a [aplicadorId], exceto os já
  /// [EstadoPontoDeAplicacao.desativado] — não há nenhuma ação disponível
  /// ao aplicador num ponto fora de operação.
  Future<List<PontoDeAplicacao>> listarMeusPontos(String aplicadorId);

  Future<PontoDeAplicacao> buscarPorId(String id);

  /// Registra uma aplicação real no ponto [id]. GEOPRAG-111 trata o
  /// subponto como um contador simples — cada chamada apenas soma mais um
  /// [Subponto] ao histórico, sem validar ordem ou posição esperada.
  Future<void> registrarSubponto(String id, Subponto subponto);
}
