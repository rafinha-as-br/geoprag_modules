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
          // Se uma linha com este `id` já existia sem aplicação (veio do pull),
          // ela passa a pertencer a esta aplicação.
          await txn.update(
            Tabelas.subpontos,
            {'aplicacao_id': aplicacao.id},
            where: 'id = ? AND aplicacao_id IS NULL',
            whereArgs: [subponto.id],
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
    final aplicacoes = await _consultar(where: 'id = ?', argumentos: [id]);
    return aplicacoes.isEmpty ? null : aplicacoes.single;
  }

  @override
  Future<List<Aplicacao>> listarPorPonto(String pontoId) =>
      _consultar(where: 'ponto_id = ?', argumentos: [pontoId]);

  /// Lê as aplicações que atendem ao [where], da mais antiga para a mais
  /// recente, com **duas** consultas ao todo (aplicações e subpontos), numa
  /// transação para os dois resultados serem do mesmo instante.
  Future<List<Aplicacao>> _consultar({
    required String where,
    required List<Object?> argumentos,
  }) => _db.transaction((txn) async {
    final linhas = await txn.query(
      Tabelas.aplicacoes,
      where: where,
      whereArgs: argumentos,
      orderBy: 'rowid',
    );
    if (linhas.isEmpty) return const <Aplicacao>[];

    final subpontosPorAplicacao = <Object?, List<Map<String, Object?>>>{};
    final subpontos = await txn.rawQuery(
      'SELECT * FROM ${Tabelas.subpontos} WHERE aplicacao_id IN '
      '(SELECT id FROM ${Tabelas.aplicacoes} WHERE $where) '
      'ORDER BY realizado_em_ms, rowid',
      argumentos,
    );
    for (final linha in subpontos) {
      (subpontosPorAplicacao[linha['aplicacao_id']] ??= []).add(linha);
    }
    return [
      for (final linha in linhas)
        ConversoresDoBanco.aplicacaoDaLinha(linha, [
          for (final s in subpontosPorAplicacao[linha['id']] ?? const [])
            ConversoresDoBanco.subpontoDaLinha(s),
        ]),
    ];
  });
}
