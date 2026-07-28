import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/distribuicao_repository.dart';
import 'distribuicao_detalhe_state.dart';
import 'distribuicao_view_model.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

/// Carrega a ficha completa de uma Distribuição específica
/// (`distribuicaoId`) para a tela de detalhe.
///
/// TODO(GEOPRAG-24): hoje `AdminNavigator.toDistribuicaoVisualizacao()` não
/// carrega um id (ver `core/admin_navigator.dart`) — o `distribuicaoId` é
/// passado pelo app consumidor ao montar este Cubit em `bootstrap.dart`;
/// falta o roteamento real repassar qual distribuição foi selecionada na
/// listagem.
class DistribuicaoDetalheCubit extends Cubit<DistribuicaoDetalheState> {
  DistribuicaoDetalheCubit(this._repository, this._distribuicaoId)
    : super(const DistribuicaoDetalheLoading()) {
    _carregar();
  }

  final DistribuicaoRepository _repository;
  final String _distribuicaoId;

  Future<void> _carregar() async {
    try {
      final distribuicao = await _repository.buscarPorId(_distribuicaoId);
      final produtoNome = await _repository.buscarNomeProduto(
        distribuicao.produtoId,
      );
      emit(
        DistribuicaoDetalheLoaded(
          DistribuicaoDetalhadaViewModel.fromEntity(distribuicao, produtoNome),
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emit(DistribuicaoDetalheError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('DistribuicaoDetalheCubit._carregar', e, stackTrace);
      emit(DistribuicaoDetalheError(AppErrorMessages.carregamentoGenerico));
    }
  }
}
