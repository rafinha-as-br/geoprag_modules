import '../../../src/state/acao_feedback.dart';
import 'ponto_de_aplicacao_view_model.dart';

sealed class PontoDeAplicacaoDetalheState {
  const PontoDeAplicacaoDetalheState();
}

class PontoDeAplicacaoDetalheLoading extends PontoDeAplicacaoDetalheState {
  const PontoDeAplicacaoDetalheLoading();
}

class PontoDeAplicacaoDetalheLoaded extends PontoDeAplicacaoDetalheState {
  final PontoDeAplicacaoDetalhadoViewModel ponto;

  /// Resultado da última ação individual (ativar/desativar/reativar/
  /// atribuir/desatribuir aplicador — GEOPRAG-110), no contrato único de
  /// feedback da GEOPRAG-77.
  final AcaoFeedback? feedback;

  /// `true` enquanto uma dessas ações está em execução — desabilita os
  /// botões da tela para evitar duplo disparo.
  final bool processando;

  const PontoDeAplicacaoDetalheLoaded(
    this.ponto, {
    this.feedback,
    this.processando = false,
  });

  PontoDeAplicacaoDetalheLoaded copyWith({
    PontoDeAplicacaoDetalhadoViewModel? ponto,
    AcaoFeedback? feedback,
    bool? processando,
    bool limparFeedback = false,
  }) {
    return PontoDeAplicacaoDetalheLoaded(
      ponto ?? this.ponto,
      feedback: limparFeedback ? null : (feedback ?? this.feedback),
      processando: processando ?? this.processando,
    );
  }
}

class PontoDeAplicacaoDetalheError extends PontoDeAplicacaoDetalheState {
  final String message;
  const PontoDeAplicacaoDetalheError(this.message);
}
