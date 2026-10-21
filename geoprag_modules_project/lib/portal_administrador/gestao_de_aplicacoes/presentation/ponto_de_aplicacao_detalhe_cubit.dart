import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/entities/ponto_de_aplicacao.dart';
import '../../../src/api/api_exceptions.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/state/acao_feedback.dart';
import '../core/aplicador_resumo_repository.dart';
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
  final AplicadorResumoRepository _aplicadorRepository;
  final String _pontoId;

  Future<void> _carregar() async => emit(await _buscar());

  /// O ponto como a tela o mostra: carregado, ou o erro com a mensagem pronta.
  Future<PontoDeAplicacaoDetalheState> _buscar() async {
    try {
      final ponto = await _repository.buscarPorId(_pontoId);
      final aplicadorNome = await _nomeDoAplicador(ponto.aplicadorId);
      return PontoDeAplicacaoDetalheLoaded(
        PontoDeAplicacaoDetalhadoViewModel.fromEntity(
          ponto,
          aplicadorNome: aplicadorNome,
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      return PontoDeAplicacaoDetalheError(e.mensagemAmigavel);
    } on ApiException catch (e) {
      return PontoDeAplicacaoDetalheError(e.mensagemAmigavel);
    } catch (e, stackTrace) {
      AppLogger.error('PontoDeAplicacaoDetalheCubit._carregar', e, stackTrace);
      return const PontoDeAplicacaoDetalheError(
        AppErrorMessages.carregamentoGenerico,
      );
    }
  }

  /// O nome do responsável é enriquecimento da tela, não o dado dela: se o
  /// aplicador vinculado não for encontrado, ou a lista de aplicadores não
  /// puder ser lida (rede, resposta fora do formato), o ponto continua sendo
  /// exibido sem o nome, em vez de a tela inteira virar erro por causa disso.
  Future<String?> _nomeDoAplicador(String? aplicadorId) async {
    if (aplicadorId == null) return null;
    try {
      for (final aplicador in await _aplicadorRepository.listar()) {
        if (aplicador.id == aplicadorId) return aplicador.nome;
      }
      return null;
    } catch (e, stackTrace) {
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

  Future<void> cancelarAplicacaoQuimica() => _executarAcao(
    () => _repository.cancelarAplicacaoQuimica(_pontoId),
    'Aplicação química cancelada — o ponto está inativo.',
  );

  /// Aplicadores candidatos para o `AtribuirAplicadorDialog`, com a
  /// contagem de pontos já atribuídos a cada um (para o destaque de carga
  /// alta) — cruza os dois repositórios disponíveis ao Cubit.
  ///
  /// Só aplicadores ativos: o servidor recusa (`409`) um desativado. Devolve
  /// `null`, com o erro no feedback da tela, se a lista não puder ser lida.
  Future<List<AplicadorParaAtribuir>?> listarAplicadoresParaAtribuir() async {
    try {
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
        for (final aplicador in aplicadores.where((a) => a.ativo))
          AplicadorParaAtribuir(
            id: aplicador.id,
            nome: aplicador.nome,
            quantidadePontosAtribuidos: contagemPorAplicador[aplicador.id] ?? 0,
          ),
      ];
    } on ApiException catch (e) {
      _avisarErro(e.mensagemAmigavel);
    } catch (e, stackTrace) {
      AppLogger.error(
        'PontoDeAplicacaoDetalheCubit.listarAplicadoresParaAtribuir',
        e,
        stackTrace,
      );
      _avisarErro(AppErrorMessages.carregamentoGenerico);
    }
    return null;
  }

  void _avisarErro(String mensagem) {
    final estado = state;
    if (estado is PontoDeAplicacaoDetalheLoaded) {
      emit(estado.copyWith(feedback: AcaoFeedbackErro(mensagem)));
    }
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
      final recarregado = await _buscar();
      if (recarregado is PontoDeAplicacaoDetalheLoaded) {
        emit(
          recarregado.copyWith(feedback: AcaoFeedbackSucesso(mensagemDeSucesso)),
        );
      } else {
        // A ação já valeu no servidor; só a releitura falhou. Trocar a tela
        // por um erro de carregamento faria o usuário repetir uma ação feita.
        emit(
          estadoAtual.copyWith(
            processando: false,
            feedback: const AcaoFeedbackErro(
              AppErrorMessages.acaoFeitaSemAtualizarATela,
            ),
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
    } on ApiException catch (e) {
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
