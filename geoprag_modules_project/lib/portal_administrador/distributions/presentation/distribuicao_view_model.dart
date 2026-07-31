import '../core/distribuicao.dart';
import '../core/produto_referencia_distribuicao.dart';
import '../core/responsavel_referencia_distribuicao.dart';

String _formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}

/// ViewModel resumida de [Distribuicao] — usada na listagem do histórico de
/// saídas, antes de abrir a ficha completa.
class DistribuicaoResumoViewModel {
  final String id;
  final String produtoNome;
  final int quantidade;
  final String unidade;
  final String responsavel;
  final String bairroResponsavel;
  final String dataEntrega;
  final String statusConfirmacao;

  const DistribuicaoResumoViewModel({
    required this.id,
    required this.produtoNome,
    required this.quantidade,
    required this.unidade,
    required this.responsavel,
    required this.bairroResponsavel,
    required this.dataEntrega,
    required this.statusConfirmacao,
  });

  factory DistribuicaoResumoViewModel.fromEntity(
    Distribuicao entity,
    String produtoNome,
  ) {
    return DistribuicaoResumoViewModel(
      id: entity.id,
      produtoNome: produtoNome,
      quantidade: entity.quantidade,
      unidade: entity.unidade,
      responsavel: entity.responsavel,
      bairroResponsavel: entity.bairroResponsavel,
      dataEntrega: _formatarData(entity.dataEntrega),
      statusConfirmacao: entity.statusConfirmacao,
    );
  }
}

/// ViewModel detalhada de [Distribuicao] — dados completos da ficha de
/// distribuição, incluindo o nome de exibição do produto (agregado de outra
/// fonte, ver [DistribuicaoRepository.buscarNomeProduto]).
class DistribuicaoDetalhadaViewModel {
  final String produtoNome;
  final int quantidade;
  final String unidade;
  final String dataEntrega;
  final String responsavel;
  final String bairroResponsavel;
  final String statusConfirmacao;

  const DistribuicaoDetalhadaViewModel({
    required this.produtoNome,
    required this.quantidade,
    required this.unidade,
    required this.dataEntrega,
    required this.responsavel,
    required this.bairroResponsavel,
    required this.statusConfirmacao,
  });

  factory DistribuicaoDetalhadaViewModel.fromEntity(
    Distribuicao entity,
    String produtoNome,
  ) {
    return DistribuicaoDetalhadaViewModel(
      produtoNome: produtoNome,
      quantidade: entity.quantidade,
      unidade: entity.unidade,
      dataEntrega: _formatarData(entity.dataEntrega),
      responsavel: entity.responsavel,
      bairroResponsavel: entity.bairroResponsavel,
      statusConfirmacao: entity.statusConfirmacao,
    );
  }
}

/// ViewModel de uma opção de produto no dropdown "Produto/Lote" do
/// formulário de nova distribuição.
class ProdutoOpcaoViewModel {
  final String id;
  final String nomeExibicao;

  const ProdutoOpcaoViewModel({required this.id, required this.nomeExibicao});

  factory ProdutoOpcaoViewModel.fromEntity(
    ProdutoReferenciaDistribuicao entity,
  ) {
    return ProdutoOpcaoViewModel(
      id: entity.id,
      nomeExibicao: entity.nomeExibicao,
    );
  }
}

/// ViewModel de uma opção de responsável no dropdown "Responsável pelo
/// Recebimento" do formulário de nova distribuição.
class ResponsavelOpcaoViewModel {
  final String id;
  final String nome;
  final String bairro;

  const ResponsavelOpcaoViewModel({
    required this.id,
    required this.nome,
    required this.bairro,
  });

  factory ResponsavelOpcaoViewModel.fromEntity(
    ResponsavelReferenciaDistribuicao entity,
  ) {
    return ResponsavelOpcaoViewModel(
      id: entity.id,
      nome: entity.nome,
      bairro: entity.bairro,
    );
  }
}
