import 'foco_recente.dart';

/// Resumo geral operacional exibido no Dashboard do Portal Administrador:
/// KPIs agregados de estoque, aplicações e denúncias, além dos registros
/// recentes de cada frente de trabalho.
class ResumoGeral {
  final int lotesAVencer;
  final int corregosComAplicacaoAtrasada;
  final int denunciasAbertas;
  final List<String> atualizacoesEstoque;
  final List<String> ultimasAplicacoes;
  final List<FocoRecente> focosRecentes;

  const ResumoGeral({
    required this.lotesAVencer,
    required this.corregosComAplicacaoAtrasada,
    required this.denunciasAbertas,
    required this.atualizacoesEstoque,
    required this.ultimasAplicacoes,
    required this.focosRecentes,
  });
}
