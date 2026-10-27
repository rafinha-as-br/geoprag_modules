import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/entities/aplicacao.dart';
import '../core/aplicador_ponto_de_aplicacao_repository.dart';
import '../core/registro_de_aplicacao_repository.dart';
import '../core/servico_de_localizacao.dart';
import 'aplicacao_de_campo_view_model.dart';
import 'tela_de_aplicacao_state.dart';

/// Controla o registro de subpontos da sessão de aplicação em andamento no
/// ponto (`pontoId`), feito pelo aplicador `aplicadorId`.
///
/// O registro passa pelo [RegistroDeAplicacaoRepository] (GEOPRAG-203): é
/// gravado no aparelho, com ou sem rede, e enviado depois. A sessão é uma
/// aplicação, aberta no primeiro subponto com o produto escolhido e a data
/// agendada que ela cumpre; os subpontos seguintes a acrescentam.
///
/// Cada subponto carrega a posição real do GPS (GEOPRAG-191). Sem posição
/// (permissão negada, GPS desligado, tempo esgotado) o subponto **não** é
/// registrado: a tela mostra a orientação e o aplicador pode tentar de novo.
class TelaDeAplicacaoCubit extends Cubit<TelaDeAplicacaoState> {
  TelaDeAplicacaoCubit(
    this._pontos,
    this._registro,
    this._localizacao,
    this._pontoId,
    this._aplicadorId,
  ) : super(const TelaDeAplicacaoLoading()) {
    _carregar();
  }

  final AplicadorPontoDeAplicacaoRepository _pontos;
  final RegistroDeAplicacaoRepository _registro;
  final ServicoDeLocalizacao _localizacao;
  final String _pontoId;
  final String _aplicadorId;

  /// A aplicação aberta por esta sessão; `null` até o primeiro subponto.
  Aplicacao? _aplicacao;

  Future<void> _carregar() async {
    try {
      final ponto = await _pontos.buscarPorId(_pontoId);
      final produtos = await _registro.listarProdutos();
      if (isClosed) return;
      emit(
        TelaDeAplicacaoEmAndamento(
          ponto: PontoParaAplicacaoViewModel.fromEntity(ponto),
          produtos: produtos,
          // Com um só produto não há o que escolher.
          produtoSelecionadoId: produtos.length == 1
              ? produtos.single.id
              : null,
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      if (!isClosed) emit(TelaDeAplicacaoError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('TelaDeAplicacaoCubit._carregar', e, stackTrace);
      if (!isClosed) {
        emit(TelaDeAplicacaoError(AppErrorMessages.carregamentoGenerico));
      }
    }
  }

  /// Escolhe o produto da aplicação. Ignorado depois do primeiro subponto.
  void selecionarProduto(String produtoId) {
    final atual = state;
    if (atual is! TelaDeAplicacaoEmAndamento ||
        atual.iniciada ||
        atual.registrando) {
      return;
    }
    emit(atual.copyWith(produtoSelecionadoId: produtoId));
  }

  /// Registra mais um subponto nesta sessão. Ignorado se a sessão já está
  /// concluída ou já há um registro em andamento.
  Future<void> registrarSubponto() async {
    final atual = state;
    if (atual is! TelaDeAplicacaoEmAndamento ||
        atual.concluida ||
        atual.registrando) {
      return;
    }
    final produtoId = atual.produtoSelecionadoId;
    final dataAgendadaId = atual.ponto.proximaDataAgendadaId;
    if (produtoId == null) {
      emit(atual.copyWith(mensagemDeErro: _mensagemSemProduto));
      return;
    }
    if (dataAgendadaId == null) {
      emit(atual.copyWith(mensagemDeErro: _mensagemSemDataPendente));
      return;
    }
    emit(atual.copyWith(registrando: true));
    try {
      final posicao = await _localizacao.obterPosicao();
      var aplicacao = _aplicacao;
      aplicacao ??= _aplicacao = await _registro.iniciarAplicacao(
        pontoId: _pontoId,
        aplicadorId: _aplicadorId,
        dataAgendadaId: dataAgendadaId,
        produtoId: produtoId,
        localizacao: LocalizacaoCapturada(
          latitude: posicao.latitude,
          longitude: posicao.longitude,
        ),
        realizadoEm: posicao.instante,
      );
      await _registro.registrarSubponto(
        aplicacaoId: aplicacao.id,
        latitude: posicao.latitude,
        longitude: posicao.longitude,
        realizadoEm: posicao.instante,
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

const _mensagemSemProduto = 'Escolha o produto antes de registrar.';
const _mensagemSemDataPendente =
    'Este ponto não tem aplicação pendente. Sincronize e tente de novo.';
