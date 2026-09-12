import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/data/mock_formulas_dosagem.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/data/mock_produtos.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/data/produto_repository_impl.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';

void main() {
  late ProdutoRepositoryImpl repository;

  setUp(() {
    repository = ProdutoRepositoryImpl();
  });

  test('listar retorna todos os produtos mockados', () async {
    final result = await repository.listar();
    expect(result.length, mockProdutos.length);
  });

  test('buscarPorId retorna o produto correspondente', () async {
    final result = await repository.buscarPorId('p1');
    expect(result.nome, 'BTI Líquido');
    expect(result.lote, 'L-001');
  });

  test('buscarPorId lança EntidadeNaoEncontradaException quando o id não existe', () {
    expect(
      () => repository.buscarPorId('inexistente'),
      throwsA(isA<EntidadeNaoEncontradaException>()),
    );
  });

  test('buscarMovimentacoes retorna o histórico do produto conhecido', () async {
    final result = await repository.buscarMovimentacoes('p1');
    expect(result, hasLength(2));
  });

  test('buscarMovimentacoes retorna lista vazia quando não há histórico mockado', () async {
    final result = await repository.buscarMovimentacoes('p2');
    expect(result, isEmpty);
  });

  test('listarFormulas retorna todas as fórmulas de dosagem mockadas', () async {
    final result = await repository.listarFormulas();
    expect(result.length, mockFormulasDosagem.length);
  });

  test(
    'registrarEntrada adiciona o produto à lista mockada, nascendo em '
    'estoque com quantidadeOriginal igual à quantidade recebida',
    () async {
      final antes = mockProdutos.length;

      final produto = await repository.registrarEntrada(
        nome: 'BTI Líquido',
        lote: 'L-999',
        dataValidade: DateTime(2027, 1, 1),
        quantidade: 300,
        unidadeMedida: 'Litros',
        licitacao: 'Pregão 01/2026',
        fornecedor: 'BioInsumos Ltda.',
      );

      expect(produto.status, 'Produto em estoque');
      expect(produto.quantidade, 300);
      expect(produto.quantidadeOriginal, 300);
      expect(mockProdutos.length, antes + 1);
      expect(mockProdutos.last, same(produto));
    },
  );

  test(
    'criarFormula resolve o nome do produto e adiciona a fórmula à lista '
    'mockada quando o produto ainda não tem uma',
    () async {
      // p3 não tem fórmula em mockFormulasDosagem — só p1 (f1) e p2 (f2).
      final antes = mockFormulasDosagem.length;

      final formula = await repository.criarFormula(
        produtoId: 'p3',
        fatorConversao: 1.8,
        distanciaCarreamento: 120,
        fatorCorrecao: 1.3,
      );

      expect(formula.produtoNome, 'BTI Líquido');
      expect(mockFormulasDosagem.length, antes + 1);
      expect(mockFormulasDosagem.last, same(formula));
    },
  );

  test(
    'criarFormula atualiza a fórmula existente do produto em vez de '
    'duplicá-la',
    () async {
      // p1 já tem fórmula (f1) em mockFormulasDosagem.
      final antes = mockFormulasDosagem.length;
      final idOriginal = mockFormulasDosagem
          .firstWhere((f) => f.produtoId == 'p1')
          .id;

      final formula = await repository.criarFormula(
        produtoId: 'p1',
        fatorConversao: 9.9,
        distanciaCarreamento: 999,
        fatorCorrecao: 9.9,
      );

      expect(formula.id, idOriginal);
      expect(mockFormulasDosagem.length, antes);
      expect(
        mockFormulasDosagem.where((f) => f.produtoId == 'p1'),
        hasLength(1),
      );
      expect(
        mockFormulasDosagem.firstWhere((f) => f.produtoId == 'p1').fatorConversao,
        9.9,
      );
    },
  );

  test(
    'criarFormula lança EntidadeNaoEncontradaException quando o produto não existe',
    () {
      expect(
        () => repository.criarFormula(
          produtoId: 'inexistente',
          fatorConversao: 1,
          distanciaCarreamento: 1,
          fatorCorrecao: 1,
        ),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );
    },
  );
}
