import '../../../src/api/sync/pull_dtos.dart';

/// O que o pull fez no banco do aparelho (GEOPRAG-202).
class ResultadoDoPull {
  const ResultadoDoPull({
    this.pontosSalvos = const [],
    this.pontosRemovidos = const [],
    this.pontosMantidos = const [],
    this.pontosIgnorados = const [],
    this.produtos = const [],
    this.cursor,
  });

  /// Pontos inseridos ou atualizados a partir da resposta.
  final List<String> pontosSalvos;

  /// Pontos que o servidor retirou do aplicador e que saíram do aparelho.
  final List<String> pontosRemovidos;

  /// Pontos que o servidor retirou do aplicador, mas que continuam no aparelho
  /// porque ainda têm registro pendente na outbox. O pull seguinte (depois do
  /// envio) os remove.
  final List<String> pontosMantidos;

  /// Pontos da resposta que não puderam ser lidos (estado desconhecido, dado
  /// inválido). Ficam como estavam no aparelho e não impedem o resto.
  final List<String> pontosIgnorados;

  /// Produtos que o aplicador pode selecionar ao registrar.
  final List<ProdutoDto> produtos;

  /// Instante do servidor para o pull incremental (GEOPRAG-206); `null` se o
  /// servidor não o enviou.
  final DateTime? cursor;
}

/// Desfecho de uma sincronização completa (envio da outbox e pull).
class ResultadoDaSincronizacao {
  const ResultadoDaSincronizacao({
    this.envioCompleto = true,
    this.pull,
    this.pullFalhou = false,
  });

  /// A outbox foi enviada até o fim (nada ficou esperando por falha).
  final bool envioCompleto;

  /// O pull que rodou, ou `null` se não foi pedido ou falhou.
  final ResultadoDoPull? pull;

  /// O pull foi pedido e não aconteceu (sem rede, erro do servidor, resposta
  /// ilegível ou envio incompleto).
  final bool pullFalhou;

  /// Tudo o que foi pedido aconteceu; falso pede uma nova tentativa depois.
  bool get concluida => envioCompleto && !pullFalhou;
}
