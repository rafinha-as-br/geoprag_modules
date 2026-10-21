import 'package:sqflite/sqflite.dart';

import 'conversores_do_banco.dart';
import 'esquema.dart';
import 'item_da_outbox.dart';
import 'outbox_dao.dart';

/// [OutboxDao] sobre o SQLite do aparelho.
class OutboxDaoSqflite implements OutboxDao {
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

  @override
  Future<void> marcarEnviando(Iterable<String> ids) async {
    if (ids.isEmpty) return;
    await _db.rawUpdate(
      'UPDATE outbox SET estado = ?, tentativas = tentativas + 1, '
      'ultima_tentativa_em = ? '
      'WHERE estado = ? AND id IN (${_marcas(ids)})',
      [
        EstadoDoItemDaOutbox.enviando.valor,
        ConversoresDoBanco.textoDoInstante(_agora()),
        EstadoDoItemDaOutbox.pendente.valor,
        ...ids,
      ],
    );
  }

  @override
  Future<void> marcarEnviado(Iterable<String> ids) async {
    if (ids.isEmpty) return;
    await _db.rawUpdate(
      'UPDATE outbox SET estado = ?, ultimo_erro = NULL '
      'WHERE id IN (${_marcas(ids)})',
      [EstadoDoItemDaOutbox.enviado.valor, ...ids],
    );
  }

  @override
  Future<void> marcarRejeitado(String id, String motivo) async {
    await _db.update(
      Tabelas.outbox,
      {'estado': EstadoDoItemDaOutbox.rejeitado.valor, 'ultimo_erro': motivo},
      where: 'id = ?',
      whereArgs: [id],
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

  static String _marcas(Iterable<Object?> valores) =>
      List.filled(valores.length, '?').join(', ');
}
