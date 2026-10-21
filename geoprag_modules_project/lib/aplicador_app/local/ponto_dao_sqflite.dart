import 'package:sqflite/sqflite.dart';

import '../../src/entities/ponto_de_aplicacao.dart';
import 'conversores_do_banco.dart';
import 'esquema.dart';
import 'ponto_dao.dart';

/// [PontoDao] sobre o SQLite do aparelho.
class PontoDaoSqflite implements PontoDao {
  PontoDaoSqflite(this._db);

  final Database _db;

  @override
  Future<void> salvar(PontoDeAplicacao ponto) =>
      _db.transaction((txn) => _gravar(txn, ponto));

  @override
  Future<void> salvarTodos(Iterable<PontoDeAplicacao> pontos) =>
      _db.transaction((txn) async {
        for (final ponto in pontos) {
          await _gravar(txn, ponto);
        }
      });

  Future<void> _gravar(DatabaseExecutor txn, PontoDeAplicacao ponto) async {
    // Atualiza sem apagar a linha: um REPLACE dispararia o ON DELETE CASCADE
    // das datas, que são regravadas logo abaixo de qualquer forma.
    final linha = ConversoresDoBanco.linhaDoPonto(ponto);
    final atualizadas = await txn.update(
      Tabelas.pontos,
      linha,
      where: 'id = ?',
      whereArgs: [ponto.id],
    );
    if (atualizadas == 0) await txn.insert(Tabelas.pontos, linha);

    await txn.delete(
      Tabelas.datasAgendadas,
      where: 'ponto_id = ?',
      whereArgs: [ponto.id],
    );
    final datas = ponto.agendamento?.datas ?? const <DataAgendada>[];
    for (var i = 0; i < datas.length; i++) {
      await txn.insert(
        Tabelas.datasAgendadas,
        ConversoresDoBanco.linhaDaData(ponto.id, datas[i], i),
      );
    }

    for (final subponto in ponto.subpontos) {
      // Só acrescenta: o subponto feito neste aparelho (com `aplicacao_id`) e o
      // que o servidor devolve com o mesmo `id` são o mesmo registro.
      await txn.insert(
        Tabelas.subpontos,
        ConversoresDoBanco.linhaDoSubponto(subponto, pontoId: ponto.id),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  @override
  Future<PontoDeAplicacao?> buscarPorId(String id) async {
    final linhas = await _db.query(
      Tabelas.pontos,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (linhas.isEmpty) return null;
    return _montar(_db, linhas.single);
  }

  @override
  Future<List<PontoDeAplicacao>> listar({String? aplicadorId}) async {
    final linhas = await _db.query(
      Tabelas.pontos,
      where: aplicadorId == null ? null : 'aplicador_id = ?',
      whereArgs: aplicadorId == null ? null : [aplicadorId],
      orderBy: 'nome COLLATE NOCASE, id',
    );
    return [for (final linha in linhas) await _montar(_db, linha)];
  }

  Future<PontoDeAplicacao> _montar(
    DatabaseExecutor executor,
    Map<String, Object?> linha,
  ) async {
    final id = linha['id']! as String;
    final datas = await executor.query(
      Tabelas.datasAgendadas,
      where: 'ponto_id = ?',
      whereArgs: [id],
      orderBy: 'ordem',
    );
    final subpontos = await executor.query(
      Tabelas.subpontos,
      where: 'ponto_id = ?',
      whereArgs: [id],
      orderBy: 'realizado_em_ms, rowid',
    );
    return ConversoresDoBanco.pontoDaLinha(
      linha,
      datas: datas,
      subpontos: [
        for (final s in subpontos) ConversoresDoBanco.subpontoDaLinha(s),
      ],
    );
  }

  @override
  Future<void> remover(String id) => _db.transaction((txn) async {
    await txn.delete(
      Tabelas.subpontos,
      where: 'ponto_id = ? AND aplicacao_id IS NULL',
      whereArgs: [id],
    );
    // As datas saem junto (ON DELETE CASCADE).
    await txn.delete(Tabelas.pontos, where: 'id = ?', whereArgs: [id]);
  });
}
