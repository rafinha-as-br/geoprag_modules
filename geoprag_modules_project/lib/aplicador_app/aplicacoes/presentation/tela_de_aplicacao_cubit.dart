import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/entities/ponto_de_aplicacao.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../core/aplicador_ponto_de_aplicacao_repository.dart';
import 'aplicacao_de_campo_view_model.dart';
import 'tela_de_aplicacao_state.dart';

/// Controla o registro de subpontos da sessão de aplicação em andamento no
/// ponto (`pontoId`).
///
/// TODO(GEOPRAG-24): latitude/longitude simuladas em [registrarSubponto] —
/// falta integração real com GPS do dispositivo.
class TelaDeAplicacaoCubit extends Cubit<TelaDeAplicacaoState> {
  TelaDeAplicacaoCubit(this._repository, this._pontoId)
    : super(const TelaDeAplicacaoLoading()) {
    _carregar();
  }

  final AplicadorPontoDeAplicacaoRepository _repository;
  final String _pontoId;

  Future<void> _carregar() async {
    try {
      final ponto = await _repository.buscarPorId(_pontoId);
      emit(
        TelaDeAplicacaoEmAndamento(
          ponto: PontoParaAplicacaoViewModel.fromEntity(ponto),
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emit(TelaDeAplicacaoError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('TelaDeAplicacaoCubit._carregar', e, stackTrace);
      emit(TelaDeAplicacaoError(AppErrorMessages.carregamentoGenerico));
    }
  }

  /// Registra mais um subponto nesta sessão — contador simples, sem
  /// validação de ordem/posição esperada (GEOPRAG-111). Ignorado se a
  /// sessão já está concluída ou já há um registro em andamento.
  Future<void> registrarSubponto() async {
    final atual = state;
    if (atual is! TelaDeAplicacaoEmAndamento ||
        atual.concluida ||
        atual.registrando) {
      return;
    }
    emit(atual.copyWith(registrando: true));
    try {
      final agora = DateTime.now();
      await _repository.registrarSubponto(
        _pontoId,
        Subponto(
          latitude: 0,
          longitude: 0,
          realizadoEm: agora,
          registradoEm: agora,
        ),
      );
      emit(
        atual.copyWith(
          subpontosRegistrados: atual.subpontosRegistrados + 1,
          registrando: false,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('TelaDeAplicacaoCubit.registrarSubponto', e, stackTrace);
      emit(atual.copyWith(registrando: false));
    }
  }
}
