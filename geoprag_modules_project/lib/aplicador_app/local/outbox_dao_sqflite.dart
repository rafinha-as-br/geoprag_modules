import 'package:sqflite/sqflite.dart';

import 'conversores_do_banco.dart';
import 'esquema.dart';
import 'item_da_outbox.dart';
import 'outbox_dao.dart';
import 'registro_da_fila.dart';

/// [OutboxDao] sobre o SQLite do aparelho.
class OutboxDaoSqflite implements OutboxDao, RegistrosDaFilaDao {
  /// [agora] é o relógio das tentativas; injetável para os testes.
  OutboxDaoSqflite(this._db, {DateTime Function()? agora})
    : _agora = agora ?? DateTime.now;

  final Database _db;
  final DateTime Function() _agora;

  @override
  Future<ItemDaOutbox?> buscarPorId(String id) async {
    final linhas = await _db.query(
      Tabelas.outbox,
      where: 'id = ?',
      whereArgs: [id],
    );
    return linhas.isEmpty
        ? null
        : ConversoresDoBanco.itemDaLinha(linhas.single);
  }

  @override
  Future<List<ItemDaOutbox>> pendentes({int? limite}) async {
    final linhas = await _db.query(
      Tabelas.outbox,
      where: 'estado = ?',
      whereArgs: [EstadoDoItemDaOutbox.pendente.valor],
      orderBy: 'criado_em_ms, rowid',
      limit: limite,
    );
    return [for (final linha in linhas) ConversoresDoBanco.itemDaLinha(linha)];
  }

  /// O SQLite antigo (builds do Android) aceita só 999 variáveis por comando:
  /// listas longas de ids são divididas em fatias deste tamanho, todas na mesma
  /// transação.
  static const int _idsPorComando = 500;

  @override
  Future<void> marcarEnviando(Iterable<String> ids) {
    final agora = ConversoresDoBanco.textoDoInstante(_agora());
    return _emFatias(
      ids,
      (txn, fatia) => txn.rawUpdate(
        'UPDATE outbox SET estado = ?, tentativas = tentativas + 1, '
        'ultima_tentativa_em = ? '
        'WHERE estado = ? AND id IN (${_marcas(fatia)})',
        [
          EstadoDoItemDaOutbox.enviando.valor,
          agora,
          EstadoDoItemDaOutbox.pendente.valor,
          ...fatia,
        ],
      ),
    );
  }

  @override
  Future<void> marcarEnviado(Iterable<String> ids) => _emFatias(
    ids,
    (txn, fatia) => txn.rawUpdate(
      'UPDATE outbox SET estado = ?, ultimo_erro = NULL '
      'WHERE id IN (${_marcas(fatia)})',
      [EstadoDoItemDaOutbox.enviado.valor, ...fatia],
    ),
  );

  @override
  Future<void> marcarRejeitado(String id, String motivo) async {
    // Uma resposta atrasada de rejeição não desfaz um envio já confirmado.
    await _db.update(
      Tabelas.outbox,
      {'estado': EstadoDoItemDaOutbox.rejeitado.valor, 'ultimo_erro': motivo},
      where: 'id = ? AND estado <> ?',
      whereArgs: [id, EstadoDoItemDaOutbox.enviado.valor],
    );
  }

  @override
  Future<void> registrarFalha(String id, String erro) async {
    await _db.update(
      Tabelas.outbox,
      {'estado': EstadoDoItemDaOutbox.pendente.valor, 'ultimo_erro': erro},
      where: 'id = ? AND estado = ?',
      whereArgs: [id, EstadoDoItemDaOutbox.enviando.valor],
    );
  }

  @override
  Future<int> reenfileirarEmAndamento() => _db.update(
    Tabelas.outbox,
    {'estado': EstadoDoItemDaOutbox.pendente.valor},
    where: 'estado = ?',
    whereArgs: [EstadoDoItemDaOutbox.enviando.valor],
  );

  @override
  Future<Map<EstadoDoItemDaOutbox, int>> contarPorEstado() async {
    final linhas = await _db.rawQuery(
      'SELECT estado, COUNT(*) AS total FROM outbox GROUP BY estado',
    );
    return {
      for (final linha in linhas)
        EstadoDoItemDaOutbox.doValor(linha['estado']! as String):
            linha['total']! as int,
    };
  }

  @override
  Future<Set<String>> pontoIdsComPendencias() async {
    final linhas = await _db.rawQuery(
      'SELECT DISTINCT ponto_id FROM outbox WHERE estado IN (?, ?)',
      [
        EstadoDoItemDaOutbox.pendente.valor,
        EstadoDoItemDaOutbox.enviando.valor,
      ],
    );
    return {for (final linha in linhas) linha['ponto_id']! as String};
  }

  @override
  Future<List<RegistroDaFila>> registrosParaExibir({
    int enviadosRecentes = 100,
  }) async {
    final linhas = await _db.rawQuery(
      'SELECT o.*, p.nome AS ponto_nome FROM outbox o '
      'LEFT JOIN pontos p ON p.id = o.ponto_id '
      'WHERE o.estado <> ? OR o.id IN ('
      'SELECT id FROM outbox WHERE estado = ? '
      'ORDER BY criado_em_ms DESC, rowid DESC LIMIT ?) '
      'ORDER BY o.criado_em_ms DESC, o.rowid DESC',
      [
        EstadoDoItemDaOutbox.enviado.valor,
        EstadoDoItemDaOutbox.enviado.valor,
        enviadosRecentes,
      ],
    );
    return [
      for (final linha in linhas)
        RegistroDaFila(
          item: ConversoresDoBanco.itemDaLinha(linha),
          pontoNome: linha['ponto_nome'] as String?,
        ),
    ];
  }

  Future<void> _emFatias(
    Iterable<String> ids,
    Future<Object?> Function(DatabaseExecutor txn, List<String> fatia) comando,
  ) async {
    final todos = ids.toList();
    if (todos.isEmpty) return;
    await _db.transaction((txn) async {
      for (var i = 0; i < todos.length; i += _idsPorComando) {
        final fim = i + _idsPorComando < todos.length
            ? i + _idsPorComando
            : todos.length;
        await comando(txn, todos.sublist(i, fim));
      }
    });
  }

  static String _marcas(Iterable<Object?> valores) =>
      List.filled(valores.length, '?').join(', ');
}
