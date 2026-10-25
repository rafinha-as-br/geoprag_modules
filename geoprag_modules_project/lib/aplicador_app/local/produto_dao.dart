import '../../src/entities/produto.dart';

/// Acesso aos produtos que o pull entregou, guardados no aparelho. Interface
/// para testes com banco em memória.
abstract interface class ProdutoDao {
  /// Insere ou atualiza os [produtos]. **Soma, nunca substitui**: o pull
  /// incremental traz só os produtos novos, então um produto ausente da resposta
  /// não foi retirado.
  Future<void> salvarTodos(Iterable<Produto> produtos);

  /// Produtos guardados, por nome.
  Future<List<Produto>> listar();
}
