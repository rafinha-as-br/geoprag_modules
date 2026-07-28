import '../core/atuacao_aplicador.dart';

/// Histórico de atuações por `aplicadorId`, usado para simular a tela de
/// detalhe enquanto não há agregação real com os módulos de aplicações e
/// distribuições.
final Map<String, List<AtuacaoAplicador>> mockAtuacoesAplicador = {
  '2': const [
    AtuacaoAplicador(
      tipo: AtuacaoAplicadorTipo.aplicacao,
      titulo: 'Aplicação Concluída',
      subtitulo: 'Córrego Gasparinho - 20/06/2026',
      valor: '50ml aplicados',
    ),
    AtuacaoAplicador(
      tipo: AtuacaoAplicadorTipo.recebimento,
      titulo: 'Recebimento Confirmado',
      subtitulo: 'Lote BTI-001 - 15/06/2026',
      valor: '500ml recebidos',
    ),
  ],
};
