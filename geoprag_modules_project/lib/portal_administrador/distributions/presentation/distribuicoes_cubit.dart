import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/distribuicao_repository.dart';
import 'distribuicao_view_model.dart';
import 'distribuicoes_state.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

/// Carrega a listagem do histórico de saídas (distribuições) para o
/// dashboard.
class DistribuicoesCubit extends Cubit<DistribuicoesState> {
  DistribuicoesCubit(this._repository) : super(const DistribuicoesLoading()) {
    _carregar();
  }

  final DistribuicaoRepository _repository;

  Future<void> _carregar() async {
    try {
      final distribuicoes = await _repository.listar();
      final resumos = await Future.wait(
        distribuicoes.map((distribuicao) async {
          final produtoNome = await _repository.buscarNomeProduto(
            distribuicao.produtoId,
          );
          return DistribuicaoResumoViewModel.fromEntity(
            distribuicao,
            produtoNome,
          );
        }),
      );
      emit(DistribuicoesLoaded(resumos));
    } on EntidadeNaoEncontradaException catch (e) {
      emit(DistribuicoesError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('DistribuicoesCubit._carregar', e, stackTrace);
      emit(DistribuicoesError(AppErrorMessages.carregamentoGenerico));
    }
  }
}
