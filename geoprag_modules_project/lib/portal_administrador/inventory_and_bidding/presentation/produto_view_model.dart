import '../core/formula_dosagem.dart';
import '../core/movimentacao_produto.dart';
import '../core/produto.dart';

/// ViewModel resumida de [Produto] — usada na listagem do dashboard de
/// estoque, antes de abrir o detalhe completo.
class ProdutoResumoViewModel {
  final String id;
  final String nome;
  final String lote;
  final String licitacao;
  final int quantidade;
  final String unidadeMedida;
  final DateTime dataValidade;
  final String status;

  const ProdutoResumoViewModel({
    required this.id,
    required this.nome,
    required this.lote,
    required this.licitacao,
    required this.quantidade,
    required this.unidadeMedida,
    required this.dataValidade,
    required this.status,
  });

  factory ProdutoResumoViewModel.fromEntity(Produto entity) {
    return ProdutoResumoViewModel(
      id: entity.id,
      nome: entity.nome,
      lote: entity.lote,
      licitacao: entity.licitacao,
      quantidade: entity.quantidade,
      unidadeMedida: entity.unidadeMedida,
      dataValidade: entity.dataValidade,
      status: entity.status,
    );
  }
}

class MovimentacaoProdutoViewModel {
  final MovimentacaoProdutoTipo tipo;
  final String titulo;
  final String subtitulo;
  final String valor;

  const MovimentacaoProdutoViewModel({
    required this.tipo,
    required this.titulo,
    required this.subtitulo,
    required this.valor,
  });

  factory MovimentacaoProdutoViewModel.fromEntity(MovimentacaoProduto entity) {
    return MovimentacaoProdutoViewModel(
      tipo: entity.tipo,
      titulo: entity.titulo,
      subtitulo: entity.subtitulo,
      valor: entity.valor,
    );
  }
}

/// ViewModel detalhada de [Produto] — dados completos do lote em estoque
/// mais o histórico de movimentações (agregado de outra fonte, ver
/// [ProdutoRepository.buscarMovimentacoes]).
class ProdutoDetalhadoViewModel {
  final String id;
  final String nome;
  final String lote;
  final String licitacao;
  final String fornecedor;
  final int quantidade;
  final int quantidadeOriginal;
  final String unidadeMedida;
  final DateTime dataValidade;
  final String status;
  final List<MovimentacaoProdutoViewModel> movimentacoes;

  const ProdutoDetalhadoViewModel({
    required this.id,
    required this.nome,
    required this.lote,
    required this.licitacao,
    required this.fornecedor,
    required this.quantidade,
    required this.quantidadeOriginal,
    required this.unidadeMedida,
    required this.dataValidade,
    required this.status,
    required this.movimentacoes,
  });

  factory ProdutoDetalhadoViewModel.fromEntity(
    Produto entity,
    List<MovimentacaoProduto> movimentacoes,
  ) {
    return ProdutoDetalhadoViewModel(
      id: entity.id,
      nome: entity.nome,
      lote: entity.lote,
      licitacao: entity.licitacao,
      fornecedor: entity.fornecedor,
      quantidade: entity.quantidade,
      quantidadeOriginal: entity.quantidadeOriginal,
      unidadeMedida: entity.unidadeMedida,
      dataValidade: entity.dataValidade,
      status: entity.status,
      movimentacoes: movimentacoes
          .map(MovimentacaoProdutoViewModel.fromEntity)
          .toList(),
    );
  }
}

/// ViewModel de [FormulaDosagem] — usada na listagem de fórmulas de dosagem
/// vinculadas a produtos do fabricante.
class FormulaDosagemViewModel {
  final String id;
  final String produtoNome;
  final double fatorConversao;
  final double distanciaCarreamento;
  final double fatorCorrecao;
  final DateTime atualizadoEm;

  const FormulaDosagemViewModel({
    required this.id,
    required this.produtoNome,
    required this.fatorConversao,
    required this.distanciaCarreamento,
    required this.fatorCorrecao,
    required this.atualizadoEm,
  });

  factory FormulaDosagemViewModel.fromEntity(FormulaDosagem entity) {
    return FormulaDosagemViewModel(
      id: entity.id,
      produtoNome: entity.produtoNome,
      fatorConversao: entity.fatorConversao,
      distanciaCarreamento: entity.distanciaCarreamento,
      fatorCorrecao: entity.fatorCorrecao,
      atualizadoEm: entity.atualizadoEm,
    );
  }
}
