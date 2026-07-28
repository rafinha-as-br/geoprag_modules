import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/produto_repository.dart';
import 'produto_detalhe_state.dart';
import 'produto_view_model.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

/// Carrega os dados completos e o histórico de movimentações de um Produto
/// específico (`produtoId`) para a tela de detalhe.
///
/// TODO(GEOPRAG-24): hoje `AdminNavigator.toEstoqueVisualizacao()` não carrega
/// um id (ver `core/admin_navigator.dart`) — o `produtoId` é passado pelo
/// app consumidor ao montar este Cubit em `bootstrap.dart`; falta o
/// roteamento real repassar qual produto foi selecionado na listagem.
class ProdutoDetalheCubit extends Cubit<ProdutoDetalheState> {
  ProdutoDetalheCubit(this._repository, this._produtoId)
    : super(const ProdutoDetalheLoading()) {
    _carregar();
  }

  final ProdutoRepository _repository;
  final String _produtoId;

  Future<void> _carregar() async {
    try {
      final produto = await _repository.buscarPorId(_produtoId);
      final movimentacoes = await _repository.buscarMovimentacoes(
        _produtoId,
      );
      emit(
        ProdutoDetalheLoaded(
          ProdutoDetalhadoViewModel.fromEntity(produto, movimentacoes),
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emit(ProdutoDetalheError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('ProdutoDetalheCubit._carregar', e, stackTrace);
      emit(ProdutoDetalheError(AppErrorMessages.carregamentoGenerico));
    }
  }
}
