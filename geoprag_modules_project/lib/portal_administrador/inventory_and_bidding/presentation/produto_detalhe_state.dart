import 'produto_view_model.dart';

sealed class ProdutoDetalheState {
  const ProdutoDetalheState();
}

class ProdutoDetalheLoading extends ProdutoDetalheState {
  const ProdutoDetalheLoading();
}

class ProdutoDetalheLoaded extends ProdutoDetalheState {
  final ProdutoDetalhadoViewModel produto;
  const ProdutoDetalheLoaded(this.produto);
}

class ProdutoDetalheError extends ProdutoDetalheState {
  final String message;
  const ProdutoDetalheError(this.message);
}
