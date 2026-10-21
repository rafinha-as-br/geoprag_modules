import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/entities/ponto_de_aplicacao.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/services/gerador_de_id.dart';
import '../core/aplicador_ponto_de_aplicacao_repository.dart';
import '../core/servico_de_localizacao.dart';
import 'aplicacao_de_campo_view_model.dart';
import 'tela_de_aplicacao_state.dart';

/// Controla o registro de subpontos da sessão de aplicação em andamento no
/// ponto (`pontoId`).
///
/// Cada subponto carrega a posição real do GPS (GEOPRAG-191). Sem posição
/// (permissão negada, GPS desligado, tempo esgotado) o subponto **não** é
/// registrado: a tela mostra a orientação e o aplicador pode tentar de novo.
class TelaDeAplicacaoCubit extends Cubit<TelaDeAplicacaoState> {
  TelaDeAplicacaoCubit(
    this._repository,
    this._localizacao,
    this._pontoId, {
    GeradorDeId? geradorDeId,
  }) : _geradorDeId = geradorDeId ?? GeradorDeIdUuid(),
       super(const TelaDeAplicacaoLoading()) {
    _carregar();
  }

  final AplicadorPontoDeAplicacaoRepository _repository;
  final ServicoDeLocalizacao _localizacao;
  final String _pontoId;
  final GeradorDeId _geradorDeId;

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
      final posicao = await _localizacao.obterPosicao();
      await _repository.registrarSubponto(
        _pontoId,
        Subponto(
          id: _geradorDeId.gerar(),
          latitude: posicao.latitude,
          longitude: posicao.longitude,
          realizadoEm: posicao.instante,
          registradoEm: posicao.instante,
        ),
      );
      if (isClosed) return;
      emit(
        atual.copyWith(
          subpontosRegistrados: atual.subpontosRegistrados + 1,
          registrando: false,
        ),
      );
    } on PosicaoIndisponivelException catch (e) {
      if (isClosed) return;
      emit(
        atual.copyWith(registrando: false, mensagemDeErro: e.mensagemAmigavel),
      );
    } catch (e, stackTrace) {
      AppLogger.error('TelaDeAplicacaoCubit.registrarSubponto', e, stackTrace);
      if (isClosed) return;
      emit(atual.copyWith(registrando: false));
    }
  }
}
