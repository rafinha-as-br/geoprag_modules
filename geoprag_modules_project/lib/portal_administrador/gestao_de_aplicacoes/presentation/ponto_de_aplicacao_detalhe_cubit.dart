import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../gerenciamento_de_aplicadores/core/aplicador_repository.dart';
import '../core/admin_ponto_de_aplicacao_repository.dart';
import 'ponto_de_aplicacao_detalhe_state.dart';
import 'ponto_de_aplicacao_view_model.dart';

/// Carrega um Ponto de Aplicação específico para a tela de detalhe.
///
/// As ações sobre o ponto (ativar, agendar, atribuir aplicador, desativar)
/// entram na issue de ações individuais da sprint — aqui a tela é só
/// leitura.
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
}
