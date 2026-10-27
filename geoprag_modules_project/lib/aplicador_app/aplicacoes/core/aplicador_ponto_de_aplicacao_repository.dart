import '../../../src/entities/ponto_de_aplicacao.dart';

/// Contrato de acesso aos pontos de aplicação atribuídos ao aplicador
/// logado no `aplicador_app` — visão restrita (só os seus pontos), em
/// contraste com `AdminPontoDeAplicacaoRepository` (visão de todos os
/// pontos do município). Mesma convenção de prefixo de
/// `AdminNavigator`/`AdminAccount`.
///
/// Só leitura, e do aparelho (GEOPRAG-203): os pontos vêm do SQLite que o pull
/// abastece. O registro de aplicação passa por `RegistroDeAplicacaoRepository`.
abstract class AplicadorPontoDeAplicacaoRepository {
  /// Pontos atribuídos a [aplicadorId], exceto os já
  /// [EstadoPontoDeAplicacao.desativado] — não há nenhuma ação disponível
  /// ao aplicador num ponto fora de operação.
  Future<List<PontoDeAplicacao>> listarMeusPontos(String aplicadorId);

  Future<PontoDeAplicacao> buscarPorId(String id);

  /// Ids dos pontos de [aplicadorId] com a aplicação em atraso (GEOPRAG-161).
  ///
  /// Calculado localmente, sem rede, pela regra de domínio compartilhada
  /// (`verificarAtraso`) — por isso funciona offline. É só um aviso: não
  /// bloqueia nenhuma ação sobre o ponto.
  Future<Set<String>> idsDePontosEmAtraso(String aplicadorId);

  /// Se o ponto [id] está com a aplicação em atraso (mesma regra e mesmas
  /// garantias de [idsDePontosEmAtraso]).
  Future<bool> estaEmAtraso(String id);
}
