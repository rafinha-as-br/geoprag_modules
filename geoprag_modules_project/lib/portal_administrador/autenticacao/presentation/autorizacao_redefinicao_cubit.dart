import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/solicitacao_redefinicao_repository.dart';
import 'autorizacao_redefinicao_state.dart';
import 'solicitacao_redefinicao_view_model.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

/// Carrega a solicitação de redefinição de senha pendente e registra a
/// decisão do Administrador principal (autorizar/negar).
class AutorizacaoRedefinicaoCubit extends Cubit<AutorizacaoRedefinicaoState> {
  AutorizacaoRedefinicaoCubit(this._repository)
    : super(const AutorizacaoRedefinicaoLoading()) {
    _carregar();
  }

  final SolicitacaoRedefinicaoRepository _repository;
  String? _id;

  Future<void> _carregar() async {
    try {
      final solicitacao = await _repository.buscarPendente();
      _id = solicitacao.id;
      emit(
        AutorizacaoRedefinicaoLoaded(
          SolicitacaoRedefinicaoViewModel.fromEntity(solicitacao),
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emit(AutorizacaoRedefinicaoError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('AutorizacaoRedefinicaoCubit._carregar', e, stackTrace);
      emit(AutorizacaoRedefinicaoError(AppErrorMessages.carregamentoGenerico));
    }
  }

  Future<void> autorizar() async {
    final id = _id;
    if (id == null) return;
    final solicitacao = await _repository.autorizar(id);
    emit(
      AutorizacaoRedefinicaoLoaded(
        SolicitacaoRedefinicaoViewModel.fromEntity(solicitacao),
      ),
    );
  }

  Future<void> negar() async {
    final id = _id;
    if (id == null) return;
    final solicitacao = await _repository.negar(id);
    emit(
      AutorizacaoRedefinicaoLoaded(
        SolicitacaoRedefinicaoViewModel.fromEntity(solicitacao),
      ),
    );
  }
}
