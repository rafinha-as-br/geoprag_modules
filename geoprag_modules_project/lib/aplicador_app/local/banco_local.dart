import 'package:sqflite/sqflite.dart';

import 'esquema.dart';

/// Banco SQLite do App Aplicador: a fonte de verdade do aparelho, onde o
/// registro é gravado primeiro, com ou sem rede (GEOPRAG-189).
///
/// O esquema é versionado por [Migracao]: banco novo roda todas, banco
/// existente só as que faltam. As chaves estrangeiras ficam ligadas.
class BancoLocal {
  BancoLocal._(this.db);

  /// Conexão aberta; os DAOs usam esta mesma instância.
  final Database db;

  /// Abre (ou cria) o banco.
  ///
  /// [fabrica] e [caminho] existem para os testes abrirem um banco em memória
  /// (`sqflite_common_ffi`); no app, ficam nos padrões (a fábrica global do
  /// `sqflite` e o arquivo [nomeDoArquivoDoBanco]). [migracoes] também é
  /// injetável para testar a migração de um esquema para o próximo.
  static Future<BancoLocal> abrir({
    DatabaseFactory? fabrica,
    String? caminho,
    List<Migracao> migracoes = migracoesDoEsquema,
  }) async {
    assert(migracoes.isNotEmpty, 'O esquema precisa de ao menos uma migração.');
    final f = fabrica ?? databaseFactory;
    final destino =
        caminho ?? '${await f.getDatabasesPath()}/$nomeDoArquivoDoBanco';
    final db = await f.openDatabase(
      destino,
      options: OpenDatabaseOptions(
        version: migracoes.last.versao,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, versao) => _aplicar(db, migracoes, 0, versao),
        onUpgrade: (db, antiga, nova) => _aplicar(db, migracoes, antiga, nova),
      ),
    );
    return BancoLocal._(db);
  }

  static Future<void> _aplicar(
    Database db,
    List<Migracao> migracoes,
    int de,
    int ate,
  ) async {
    for (final migracao in migracoes) {
      if (migracao.versao <= de || migracao.versao > ate) continue;
      for (final comando in migracao.comandos) {
        await db.execute(comando);
      }
    }
  }

  Future<void> fechar() => db.close();
}
