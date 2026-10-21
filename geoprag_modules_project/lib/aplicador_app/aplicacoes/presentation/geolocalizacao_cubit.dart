import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/entities/ponto_de_aplicacao.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../core/aplicador_ponto_de_aplicacao_repository.dart';
import '../core/regra_de_chegada.dart';
import '../core/servico_de_localizacao.dart';
import 'aplicacao_de_campo_view_model.dart';
import 'geolocalizacao_state.dart';

/// Carrega o ponto de aplicação (`pontoId`) e valida a chegada do aplicador
/// ao ponto com o GPS real do aparelho (GEOPRAG-191).
///
/// A regra é a provisória de [RegraDeChegada]: distância até o primeiro
/// subponto já registrado do ponto. Na primeira aplicação do ponto não há
/// subponto, a chegada não é validada e a verificação libera o registro sem
/// nem ler o GPS (a posição será capturada no próprio registro).
class GeolocalizacaoCubit extends Cubit<GeolocalizacaoState> {
  GeolocalizacaoCubit(this._repository, this._localizacao, this._pontoId)
    : super(const GeolocalizacaoLoading()) {
    _carregar();
  }

  final AplicadorPontoDeAplicacaoRepository _repository;
  final ServicoDeLocalizacao _localizacao;
  final String _pontoId;

  Subponto? _primeiroSubponto;
  bool _verificando = false;

  Future<void> _carregar() async {
    try {
      final ponto = await _repository.buscarPorId(_pontoId);
      _primeiroSubponto = ponto.primeiraExecucao;
      if (isClosed) return;
      emit(
        GeolocalizacaoLoaded(
          ponto: PontoParaAplicacaoViewModel.fromEntity(ponto),
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      if (!isClosed) emit(GeolocalizacaoError(e.mensagemAmigavel));
      return;
    } catch (e, stackTrace) {
      AppLogger.error('GeolocalizacaoCubit._carregar', e, stackTrace);
      if (!isClosed) {
        emit(GeolocalizacaoError(AppErrorMessages.carregamentoGenerico));
      }
      return;
    }
    await verificarChegada();
  }

  /// Lê o GPS e confirma (ou não) a chegada ao ponto. Pode ser chamado de novo
  /// depois de um [ChegadaSemPosicao] ou [ChegadaForaDoRaio]; ignorado enquanto
  /// uma leitura está em andamento.
  Future<void> verificarChegada() async {
    final atual = state;
    if (atual is! GeolocalizacaoLoaded || _verificando) return;
    _verificando = true;
    if (atual.verificacao is! ChegadaVerificando) {
      emit(atual.copyWith(verificacao: const ChegadaVerificando()));
    }
    final VerificacaoDeChegada resultado;
    try {
      resultado = await _avaliar();
    } finally {
      _verificando = false;
    }
    if (isClosed) return;
    emit(atual.copyWith(verificacao: resultado));
  }

  Future<VerificacaoDeChegada> _avaliar() async {
    if (_primeiroSubponto == null) return const ChegadaConfirmada();
    try {
      final posicao = await _localizacao.obterPosicao();
      return switch (RegraDeChegada.avaliar(
        atual: posicao,
        primeiroSubponto: _primeiroSubponto,
      )) {
        SemValidacaoDeChegada() => const ChegadaConfirmada(),
        DentroDoRaio(:final distanciaMetros) => ChegadaConfirmada(
          distanciaMetros: distanciaMetros,
        ),
        ForaDoRaio(:final distanciaMetros) => ChegadaForaDoRaio(
          distanciaMetros,
        ),
      };
    } on PosicaoIndisponivelException catch (e) {
      return ChegadaSemPosicao(e.mensagemAmigavel);
    } catch (e, stackTrace) {
      AppLogger.error('GeolocalizacaoCubit.verificarChegada', e, stackTrace);
      return const ChegadaSemPosicao(AppErrorMessages.localizacaoIndisponivel);
    }
  }
}
