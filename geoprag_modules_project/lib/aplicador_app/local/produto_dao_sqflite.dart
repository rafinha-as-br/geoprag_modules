import 'package:sqflite/sqflite.dart';

import '../../src/entities/produto.dart';
import 'esquema.dart';
import 'produto_dao.dart';

/// [ProdutoDao] sobre o SQLite do aparelho.
class ProdutoDaoSqflite implements ProdutoDao {
  ProdutoDaoSqflite(this._db);

  final Database _db;

  @override
  Future<void> salvarTodos(Iterable<Produto> produtos) async {
    if (produtos.isEmpty) return;
    final lote = _db.batch();
    for (final produto in produtos) {
      lote.insert(Tabelas.produtos, {
        'id': produto.id,
        'nome': produto.nome,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await lote.commit(noResult: true);
  }

  @override
  Future<List<Produto>> listar() async {
    final linhas = await _db.query(
      Tabelas.produtos,
      orderBy: 'nome COLLATE NOCASE, id',
    );
    return [
      for (final linha in linhas)
        Produto(id: linha['id']! as String, nome: linha['nome']! as String),
    ];
  }
}
