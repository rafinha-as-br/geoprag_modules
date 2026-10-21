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
    final pontos = await _consultar(where: 'id = ?', argumentos: [id]);
    return pontos.isEmpty ? null : pontos.single;
  }

  @override
  Future<List<PontoDeAplicacao>> listar({String? aplicadorId}) => _consultar(
    where: aplicadorId == null ? null : 'aplicador_id = ?',
    argumentos: aplicadorId == null ? null : [aplicadorId],
  );

  /// Lê os pontos que atendem ao [where], por nome, com **três** consultas ao
  /// todo (pontos, datas e subpontos), e não duas por ponto, numa transação
  /// para os três resultados serem do mesmo instante.
  Future<List<PontoDeAplicacao>> _consultar({
    String? where,
    List<Object?>? argumentos,
  }) => _db.transaction((txn) async {
    final linhas = await txn.query(
      Tabelas.pontos,
      where: where,
      whereArgs: argumentos,
      orderBy: 'nome COLLATE NOCASE, id',
    );
    if (linhas.isEmpty) return const <PontoDeAplicacao>[];

    final filtro = where == null ? '' : ' WHERE $where';
    final datas = _agruparPorPonto(
      await txn.rawQuery(
        'SELECT * FROM ${Tabelas.datasAgendadas} '
        'WHERE ponto_id IN (SELECT id FROM ${Tabelas.pontos}$filtro) '
        'ORDER BY ordem',
        argumentos,
      ),
    );
    final subpontos = _agruparPorPonto(
      await txn.rawQuery(
        'SELECT * FROM ${Tabelas.subpontos} '
        'WHERE ponto_id IN (SELECT id FROM ${Tabelas.pontos}$filtro) '
        'ORDER BY realizado_em_ms, rowid',
        argumentos,
      ),
    );
    return [
      for (final linha in linhas)
        ConversoresDoBanco.pontoDaLinha(
          linha,
          datas: datas[linha['id']] ?? const [],
          subpontos: [
            for (final s in subpontos[linha['id']] ?? const [])
              ConversoresDoBanco.subpontoDaLinha(s),
          ],
        ),
    ];
  });

  static Map<Object?, List<Map<String, Object?>>> _agruparPorPonto(
    List<Map<String, Object?>> linhas,
  ) {
    final grupos = <Object?, List<Map<String, Object?>>>{};
    for (final linha in linhas) {
      (grupos[linha['ponto_id']] ??= []).add(linha);
    }
    return grupos;
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
