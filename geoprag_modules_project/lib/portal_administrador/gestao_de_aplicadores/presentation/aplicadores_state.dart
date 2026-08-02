import 'aplicador_view_model.dart';

/// Filtro de status aplicado à listagem do dashboard de Aplicadores.
enum FiltroStatusAplicador { todos, ativos, desativados }

sealed class AplicadoresState {
  const AplicadoresState();
}

class AplicadoresLoading extends AplicadoresState {
  const AplicadoresLoading();
}

class AplicadoresLoaded extends AplicadoresState {
  final List<AplicadorResumoViewModel> aplicadores;
  final FiltroStatusAplicador filtro;
  final Set<String> selecionados;
  final bool processandoAcaoEmMassa;

  const AplicadoresLoaded({
    required this.aplicadores,
    this.filtro = FiltroStatusAplicador.todos,
    this.selecionados = const {},
    this.processandoAcaoEmMassa = false,
  });

  /// Aplicadores após o filtro de status ser aplicado — é esta lista que a
  /// tela deve exibir, nunca [aplicadores] diretamente.
  List<AplicadorResumoViewModel> get aplicadoresFiltrados {
    return switch (filtro) {
      FiltroStatusAplicador.todos => aplicadores,
      FiltroStatusAplicador.ativos =>
        aplicadores.where((a) => a.status == 'ativo').toList(),
      FiltroStatusAplicador.desativados =>
        aplicadores.where((a) => a.status == 'desativado').toList(),
    };
  }

  AplicadoresLoaded copyWith({
    List<AplicadorResumoViewModel>? aplicadores,
    FiltroStatusAplicador? filtro,
    Set<String>? selecionados,
    bool? processandoAcaoEmMassa,
  }) {
    return AplicadoresLoaded(
      aplicadores: aplicadores ?? this.aplicadores,
      filtro: filtro ?? this.filtro,
      selecionados: selecionados ?? this.selecionados,
      processandoAcaoEmMassa:
          processandoAcaoEmMassa ?? this.processandoAcaoEmMassa,
    );
  }
}

class AplicadoresError extends AplicadoresState {
  final String message;
  const AplicadoresError(this.message);
}
