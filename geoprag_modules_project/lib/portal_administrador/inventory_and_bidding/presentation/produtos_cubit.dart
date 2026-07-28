import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/produto_repository.dart';
import 'produto_view_model.dart';
import 'produtos_state.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

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
    } on EntidadeNaoEncontradaException catch (e) {
      emit(ProdutosError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('ProdutosCubit._carregar', e, stackTrace);
      emit(ProdutosError(AppErrorMessages.carregamentoGenerico));
    }
  }
}
