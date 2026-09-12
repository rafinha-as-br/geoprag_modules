import '../core/insumo.dart';

/// ViewModel do card de "Estoque Atual" exibido em `ListaDeInsumosScreen` —
/// já com quantidade e data formatadas, mais a contagem de recebimentos
/// pendentes (agregado de `RecebimentoRepository.listarPendentes`).
class EstoqueAtualViewModel {
  final String produtoNome;
  final String quantidadeFormatada;
  final String atualizadoEmDescricao;
  final int recebimentosPendentesCount;

  const EstoqueAtualViewModel({
    required this.produtoNome,
    required this.quantidadeFormatada,
    required this.atualizadoEmDescricao,
    required this.recebimentosPendentesCount,
  });

  factory EstoqueAtualViewModel.fromEntity(
    Insumo insumo,
    int recebimentosPendentesCount,
  ) {
    return EstoqueAtualViewModel(
      produtoNome: insumo.nome,
      quantidadeFormatada: _formatarQuantidade(insumo),
      atualizadoEmDescricao: _formatarAtualizacao(
        insumo.dataUltimaAtualizacao,
      ),
      recebimentosPendentesCount: recebimentosPendentesCount,
    );
  }

  String get recebimentosPendentesDescricao {
    if (recebimentosPendentesCount == 0) return 'Nenhum produto a caminho';
    if (recebimentosPendentesCount == 1) return '1 produto a caminho';
    return '$recebimentosPendentesCount produtos a caminho';
  }

  static String _formatarQuantidade(Insumo insumo) {
    final quantidade = insumo.quantidadeEmEstoque;
    final valor = quantidade % 1 == 0
        ? quantidade.toStringAsFixed(0)
        : quantidade.toString();
    return '$valor ${insumo.unidadeMedida}';
  }

  static String _formatarAtualizacao(DateTime data) {
    final hoje = DateTime.now();
    final mesmoDia =
        data.year == hoje.year &&
        data.month == hoje.month &&
        data.day == hoje.day;
    if (mesmoDia) return 'Última atualização hoje';
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return 'Última atualização em $dia/$mes/${data.year}';
  }
}
