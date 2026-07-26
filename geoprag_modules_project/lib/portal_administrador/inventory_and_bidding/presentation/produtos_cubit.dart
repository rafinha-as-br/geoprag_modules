import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/produto_repository.dart';
import 'produto_view_model.dart';
import 'produtos_state.dart';

/// Carrega a listagem de Produtos em estoque para o dashboard.
class ProdutosCubit extends Cubit<ProdutosState> {
  ProdutosCubit(this._repository) : super(const ProdutosLoading()) {
    _carregar();
  }

  final ProdutoRepository _repository;

  Future<void> _carregar() async {
    try {
      final produtos = await _repository.listar();
      emit(
        ProdutosLoaded(
          produtos.map(ProdutoResumoViewModel.fromEntity).toList(),
        ),
      );
    } catch (e) {
      emit(ProdutosError(e.toString()));
    }
  }
}
