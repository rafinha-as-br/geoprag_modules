import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/aplicador_repository.dart';
import 'aplicador_view_model.dart';
import 'aplicadores_state.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

/// Carrega a listagem de Aplicadores cadastrados para o dashboard, e
/// orquestra o filtro por status e as ações em massa de ativação/desativação.
class AplicadoresCubit extends Cubit<AplicadoresState> {
  AplicadoresCubit(this._repository) : super(const AplicadoresLoading()) {
    _carregar();
  }

  final AplicadorRepository _repository;

  Future<void> _carregar({
    FiltroStatusAplicador filtro = FiltroStatusAplicador.todos,
  }) async {
    try {
      final aplicadores = await _repository.listar();
      emit(
        AplicadoresLoaded(
          aplicadores: aplicadores.map(AplicadorResumoViewModel.fromEntity).toList(),
          filtro: filtro,
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emit(AplicadoresError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('AplicadoresCubit._carregar', e, stackTrace);
      emit(AplicadoresError(AppErrorMessages.carregamentoGenerico));
    }
  }

  /// Troca o filtro de status exibido — limpa a seleção em massa atual, já
  /// que ela pode incluir ids que deixam de estar visíveis com o novo filtro.
  void alterarFiltro(FiltroStatusAplicador filtro) {
    final state = this.state;
    if (state is! AplicadoresLoaded) return;
    emit(state.copyWith(filtro: filtro, selecionados: const {}));
  }

  void alternarSelecao(String id) {
    final state = this.state;
    if (state is! AplicadoresLoaded) return;
    final selecionados = Set<String>.from(state.selecionados);
    if (!selecionados.remove(id)) {
      selecionados.add(id);
    }
    emit(state.copyWith(selecionados: selecionados));
  }

  /// Seleciona todos os aplicadores atualmente visíveis (após o filtro), ou
  /// limpa a seleção se todos já estiverem selecionados.
  void alternarSelecaoDeTodosVisiveis() {
    final state = this.state;
    if (state is! AplicadoresLoaded) return;
    final idsVisiveis = state.aplicadoresFiltrados.map((a) => a.id).toSet();
    final todosJaSelecionados =
        idsVisiveis.isNotEmpty && idsVisiveis.every(state.selecionados.contains);
    emit(
      state.copyWith(
        selecionados: todosJaSelecionados ? const {} : idsVisiveis,
      ),
    );
  }

  void limparSelecao() {
    final state = this.state;
    if (state is! AplicadoresLoaded) return;
    emit(state.copyWith(selecionados: const {}));
  }

  Future<void> ativarSelecionados() => _aplicarAcaoEmMassa(_repository.ativar);

  Future<void> desativarSelecionados() =>
      _aplicarAcaoEmMassa(_repository.desativar);

  Future<void> _aplicarAcaoEmMassa(
    Future<void> Function(String id) acao,
  ) async {
    final state = this.state;
    if (state is! AplicadoresLoaded || state.selecionados.isEmpty) return;

    final filtroAtual = state.filtro;
    emit(state.copyWith(processandoAcaoEmMassa: true));
    try {
      for (final id in state.selecionados) {
        await acao(id);
      }
      await _carregar(filtro: filtroAtual);
    } on EntidadeNaoEncontradaException catch (e) {
      emit(AplicadoresError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('AplicadoresCubit._aplicarAcaoEmMassa', e, stackTrace);
      emit(AplicadoresError(AppErrorMessages.carregamentoGenerico));
    }
  }
}
