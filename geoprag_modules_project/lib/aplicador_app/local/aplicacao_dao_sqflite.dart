import 'package:sqflite/sqflite.dart';

import '../../src/entities/aplicacao.dart';
import 'aplicacao_dao.dart';
import 'conversores_do_banco.dart';
import 'esquema.dart';
import 'item_da_outbox.dart';

/// [AplicacaoDao] sobre o SQLite do aparelho.
class AplicacaoDaoSqflite implements AplicacaoDao {
  AplicacaoDaoSqflite(this._db);

  final Database _db;

  @override
  Future<void> gravarComOutbox(Aplicacao aplicacao, List<ItemDaOutbox> itens) =>
      _db.transaction((txn) async {
        // Append-only: o cabeçalho e os subpontos que já existem não mudam.
        await txn.insert(
          Tabelas.aplicacoes,
          ConversoresDoBanco.linhaDaAplicacao(aplicacao),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        for (final subponto in aplicacao.subpontos) {
          await txn.insert(
            Tabelas.subpontos,
            ConversoresDoBanco.linhaDoSubponto(
              subponto,
              pontoId: aplicacao.pontoId,
              aplicacaoId: aplicacao.id,
            ),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
        // Sem `ignore`: um item repetido derruba a transação inteira, e a
        // aplicação não entra sem o item que a leva ao servidor.
        for (final item in itens) {
          await txn.insert(
            Tabelas.outbox,
            ConversoresDoBanco.linhaDoItem(item),
          );
        }
      });

  @override
  Future<Aplicacao?> buscarPorId(String id) async {
    final linhas = await _db.query(
      Tabelas.aplicacoes,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (linhas.isEmpty) return null;
    return _montar(linhas.single);
  }

  @override
  Future<List<Aplicacao>> listarPorPonto(String pontoId) async {
    final linhas = await _db.query(
      Tabelas.aplicacoes,
      where: 'ponto_id = ?',
      whereArgs: [pontoId],
      orderBy: 'rowid',
    );
    return [for (final linha in linhas) await _montar(linha)];
  }

  Future<Aplicacao> _montar(Map<String, Object?> linha) async {
    final subpontos = await _db.query(
      Tabelas.subpontos,
      where: 'aplicacao_id = ?',
      whereArgs: [linha['id']],
      orderBy: 'realizado_em_ms, rowid',
    );
    return ConversoresDoBanco.aplicacaoDaLinha(linha, [
      for (final s in subpontos) ConversoresDoBanco.subpontoDaLinha(s),
    ]);
  }
}
