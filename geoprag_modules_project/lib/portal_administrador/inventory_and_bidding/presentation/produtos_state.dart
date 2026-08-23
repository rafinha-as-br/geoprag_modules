import 'produto_view_model.dart';

sealed class ProdutosState {
  const ProdutosState();
}

class ProdutosLoading extends ProdutosState {
  const ProdutosLoading();
}

class ProdutosLoaded extends ProdutosState {
  final List<ProdutoResumoViewModel> produtos;
  const ProdutosLoaded(this.produtos);
}

class ProdutosError extends ProdutosState {
  final String message;
  const ProdutosError(this.message);
}
