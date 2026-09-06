import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/entities/ponto_de_aplicacao.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/state/acao_feedback.dart';
import '../../gerenciamento_de_aplicadores/core/aplicador_repository.dart';
import '../core/admin_ponto_de_aplicacao_repository.dart';
import 'ponto_de_aplicacao_detalhe_state.dart';
import 'ponto_de_aplicacao_view_model.dart';
import 'widgets/atribuir_aplicador_dialog.dart';

/// Carrega um Ponto de Aplicação específico para a tela de detalhe, e
/// orquestra as ações individuais sobre ele (GEOPRAG-110): ativar
/// (agendamento), desativar/reativar, atribuir/desatribuir aplicador. Os
/// diálogos (que precisam de `BuildContext`) ficam a cargo da tela — o
/// Cubit nunca recebe `BuildContext`, só o dado já coletado (ex.:
/// `Agendamento`, `aplicadorId`).
class PontoDeAplicacaoDetalheCubit
    extends Cubit<PontoDeAplicacaoDetalheState> {
  PontoDeAplicacaoDetalheCubit(
    this._repository,
    this._aplicadorRepository,
    this._pontoId,
  ) : super(const PontoDeAplicacaoDetalheLoading()) {
    _carregar();
  }

  final AdminPontoDeAplicacaoRepository _repository;
  final AplicadorRepository _aplicadorRepository;
  final String _pontoId;

  Future<void> _carregar() async {
    try {
      final ponto = await _repository.buscarPorId(_pontoId);
      final aplicadorNome = await _nomeDoAplicador(ponto.aplicadorId);
      emit(
        PontoDeAplicacaoDetalheLoaded(
          PontoDeAplicacaoDetalhadoViewModel.fromEntity(
            ponto,
            aplicadorNome: aplicadorNome,
          ),
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emit(PontoDeAplicacaoDetalheError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('PontoDeAplicacaoDetalheCubit._carregar', e, stackTrace);
      emit(
        const PontoDeAplicacaoDetalheError(
          AppErrorMessages.carregamentoGenerico,
        ),
      );
    }
  }

  /// O nome do responsável é enriquecimento da tela, não o dado dela: se o
  /// aplicador vinculado não for encontrado, o ponto continua sendo exibido
  /// sem o nome, em vez de a tela inteira virar erro por causa de um
  /// cadastro de aplicador ausente.
  Future<String?> _nomeDoAplicador(String? aplicadorId) async {
    if (aplicadorId == null) return null;
    try {
      return (await _aplicadorRepository.buscarPorId(aplicadorId)).nome;
    } on EntidadeNaoEncontradaException catch (e, stackTrace) {
      AppLogger.error(
        'PontoDeAplicacaoDetalheCubit._nomeDoAplicador',
        e,
        stackTrace,
      );
      return null;
    }
  }

  Future<void> ativar(Agendamento agendamento) => _executarAcao(
    () => _repository.ativar(_pontoId, agendamento),
    'Ciclo ativado com sucesso.',
  );

  Future<void> desativar() => _executarAcao(
    () => _repository.desativar(_pontoId),
    'Ponto desativado.',
  );

  Future<void> reativar() =>
      _executarAcao(() => _repository.reativar(_pontoId), 'Ponto reativado.');

  Future<void> atribuirAplicador(String aplicadorId) => _executarAcao(
    () => _repository.atribuirAplicador(_pontoId, aplicadorId),
    'Aplicador atribuído com sucesso.',
  );

  Future<void> desatribuirAplicador() => _executarAcao(
    () => _repository.desatribuirAplicador(_pontoId),
    'Aplicador removido.',
  );

  /// Aplicadores candidatos para o `AtribuirAplicadorDialog`, com a
  /// contagem de pontos já atribuídos a cada um (para o destaque de carga
  /// alta) — cruza os dois repositórios disponíveis ao Cubit.
  Future<List<AplicadorParaAtribuir>> listarAplicadoresParaAtribuir() async {
    final aplicadores = await _aplicadorRepository.listar();
    final pontos = await _repository.listar();
    final contagemPorAplicador = <String, int>{};
    for (final ponto in pontos) {
      final id = ponto.aplicadorId;
      if (id != null) {
        contagemPorAplicador[id] = (contagemPorAplicador[id] ?? 0) + 1;
      }
    }
    return [
      for (final aplicador in aplicadores)
        AplicadorParaAtribuir(
          id: aplicador.id,
          nome: aplicador.nome,
          bairro: aplicador.bairro ?? 'Bairro não informado',
          quantidadePontosAtribuidos: contagemPorAplicador[aplicador.id] ?? 0,
        ),
    ];
  }

  /// Executa uma ação individual (ativar/desativar/reativar/atribuir ou
  /// desatribuir aplicador), recarrega o ponto e emite o feedback do
  /// resultado — sucesso ou erro amigável, nunca uma exceção crua na tela.
  Future<void> _executarAcao(
    Future<void> Function() acao,
    String mensagemDeSucesso,
  ) async {
    final estadoAtual = state;
    if (estadoAtual is! PontoDeAplicacaoDetalheLoaded) return;

    emit(estadoAtual.copyWith(processando: true, limparFeedback: true));
    try {
      await acao();
      await _carregar();
      final estadoRecarregado = state;
      if (estadoRecarregado is PontoDeAplicacaoDetalheLoaded) {
        emit(
          estadoRecarregado.copyWith(
            feedback: AcaoFeedbackSucesso(mensagemDeSucesso),
          ),
        );
      }
    } on EntidadeNaoEncontradaException catch (e) {
      emit(
        estadoAtual.copyWith(
          processando: false,
          feedback: AcaoFeedbackErro(e.mensagemAmigavel),
        ),
      );
    } on OperacaoNaoPermitidaException catch (e) {
      emit(
        estadoAtual.copyWith(
          processando: false,
          feedback: AcaoFeedbackErro(e.mensagemAmigavel),
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('PontoDeAplicacaoDetalheCubit._executarAcao', e, stackTrace);
      emit(
        estadoAtual.copyWith(
          processando: false,
          feedback: const AcaoFeedbackErro(AppErrorMessages.carregamentoGenerico),
        ),
      );
    }
  }
}
