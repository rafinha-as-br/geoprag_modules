import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/formula_dosagem.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/movimentacao_produto.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/produto.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/presentation/produto_view_model.dart';

void main() {
  final produto = Produto(
    id: 'p1',
    nome: 'BTI Líquido',
    lote: 'L-001',
    dataValidade: DateTime(2026, 12, 1),
    status: 'Produto em estoque',
    quantidade: 50,
    quantidadeOriginal: 1000,
    unidadeMedida: 'Litros',
    licitacao: 'Pregão 01/2026',
    fornecedor: 'BioInsumos Ltda.',
  );

  const movimentacao = MovimentacaoProduto(
    tipo: MovimentacaoProdutoTipo.saida,
    titulo: 'Saída para Belchior Alto',
    subtitulo: 'Resp: João Silva - 05/07/2026',
    valor: '10 Litros',
  );

  group('ProdutoResumoViewModel.fromEntity', () {
    test('mapeia todos os campos sem alteração', () {
      final viewModel = ProdutoResumoViewModel.fromEntity(produto);

      expect(viewModel.id, 'p1');
      expect(viewModel.nome, 'BTI Líquido');
      expect(viewModel.lote, 'L-001');
      expect(viewModel.licitacao, 'Pregão 01/2026');
      expect(viewModel.quantidade, 50);
      expect(viewModel.unidadeMedida, 'Litros');
      expect(viewModel.dataValidade, produto.dataValidade);
      expect(viewModel.status, 'Produto em estoque');
    });
  });

  group('MovimentacaoProdutoViewModel.fromEntity', () {
    test('mapeia todos os campos sem alteração', () {
      final viewModel = MovimentacaoProdutoViewModel.fromEntity(movimentacao);

      expect(viewModel.tipo, MovimentacaoProdutoTipo.saida);
      expect(viewModel.titulo, 'Saída para Belchior Alto');
      expect(viewModel.valor, '10 Litros');
    });
  });

  group('ProdutoDetalhadoViewModel.fromEntity', () {
    test('mapeia o produto e as movimentações agregadas', () {
      final viewModel = ProdutoDetalhadoViewModel.fromEntity(produto, [
        movimentacao,
      ]);

      expect(viewModel.id, 'p1');
      expect(viewModel.fornecedor, 'BioInsumos Ltda.');
      expect(viewModel.quantidadeOriginal, 1000);
      expect(viewModel.movimentacoes, hasLength(1));
      expect(viewModel.movimentacoes.first.titulo, 'Saída para Belchior Alto');
    });

    test('movimentacoes fica vazia quando não há histórico', () {
      final viewModel = ProdutoDetalhadoViewModel.fromEntity(produto, []);
      expect(viewModel.movimentacoes, isEmpty);
    });
  });

  group('FormulaDosagemViewModel.fromEntity', () {
    test('mapeia todos os campos sem alteração', () {
      final formulaValida = FormulaDosagem(
        id: 'f1',
        produtoId: 'p1',
        produtoNome: 'BTI Líquido',
        fatorConversao: 1.5,
        distanciaCarreamento: 150,
        fatorCorrecao: 1.2,
        atualizadoEm: DateTime(1970),
      );

      final viewModel = FormulaDosagemViewModel.fromEntity(formulaValida);

      expect(viewModel.id, 'f1');
      expect(viewModel.produtoNome, 'BTI Líquido');
      expect(viewModel.fatorConversao, 1.5);
      expect(viewModel.distanciaCarreamento, 150);
      expect(viewModel.fatorCorrecao, 1.2);
    });
  });

  group('EntregasLicitacaoViewModel.agrupar', () {
    Produto entrega(String id, String licitacao, int original, String un) =>
        Produto(
          id: id,
          nome: 'BTI',
          lote: 'L-$id',
          dataValidade: DateTime(2026, 12, 1),
          status: 'Produto em estoque',
          quantidade: 1,
          quantidadeOriginal: original,
          unidadeMedida: un,
          licitacao: licitacao,
          fornecedor: 'BioInsumos Ltda.',
        );

    test('agrupa por licitação e soma o volume recebido por unidade', () {
      final grupos = EntregasLicitacaoViewModel.agrupar(
        [
          entrega('1', 'Pregão 01/2026', 300, 'Litros'),
          entrega('2', 'Pregão 02/2026', 100, 'Kg'),
          entrega('3', 'Pregão 01/2026', 300, 'Litros'),
          entrega('4', 'Pregão 01/2026', 50, 'Kg'),
        ].map(ProdutoResumoViewModel.fromEntity).toList(),
      );

      expect(grupos.map((g) => g.licitacao), [
        'Pregão 01/2026',
        'Pregão 02/2026',
      ]);
      expect(grupos.first.entregas.map((e) => e.id), ['1', '3', '4']);
      expect(grupos.first.totalPorUnidade, {'Litros': 600, 'Kg': 50});
      expect(grupos.last.totalPorUnidade, {'Kg': 100});
    });

    test('lista vazia não gera grupos', () {
      expect(EntregasLicitacaoViewModel.agrupar(const []), isEmpty);
    });
  });
}
