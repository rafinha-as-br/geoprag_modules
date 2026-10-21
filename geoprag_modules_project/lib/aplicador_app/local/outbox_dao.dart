import 'item_da_outbox.dart';

/// Acesso à outbox (fila de envio). Interface para que o serviço de
/// sincronização e o repositório offline-first possam ser testados com um
/// banco em memória (ou com `mocktail`).
///
/// Os itens entram na outbox junto com a aplicação, na mesma transação, por
/// [AplicacaoDao.gravarComOutbox]; este DAO só consulta e muda o estado deles.
abstract interface class OutboxDao {
  Future<ItemDaOutbox?> buscarPorId(String id);

  /// Itens `PENDENTE`, do mais antigo para o mais recente. [limite] corta o
  /// lote (o servidor aceita no máximo 500 por envio).
  Future<List<ItemDaOutbox>> pendentes({int? limite});

  /// `PENDENTE` → `ENVIANDO`: soma uma tentativa e guarda o instante dela.
  /// Itens em outro estado são ignorados.
  Future<void> marcarEnviando(Iterable<String> ids);

  /// → `ENVIADO` (o servidor respondeu `CRIADO` ou `DUPLICADO`); limpa o
  /// último erro.
  Future<void> marcarEnviado(Iterable<String> ids);

  /// → `REJEITADO` com o [motivo] do servidor. Não volta à fila sozinho.
  Future<void> marcarRejeitado(String id, String motivo);

  /// `ENVIANDO` → `PENDENTE` com o [erro] da falha de rede ou timeout. O
  /// registro nunca se perde: só espera a próxima tentativa.
  Future<void> registrarFalha(String id, String erro);

  /// Devolve à fila os itens que ficaram `ENVIANDO` (o app fechou no meio de um
  /// envio). Chamado ao abrir o app. Devolve quantos voltaram.
  Future<int> reenfileirarEmAndamento();

  Future<Map<EstadoDoItemDaOutbox, int>> contarPorEstado();

  /// Ids dos pontos com registro `PENDENTE` ou `ENVIANDO`: o pull não pode
  /// apagar esses pontos do aparelho.
  Future<Set<String>> pontoIdsComPendencias();
}
