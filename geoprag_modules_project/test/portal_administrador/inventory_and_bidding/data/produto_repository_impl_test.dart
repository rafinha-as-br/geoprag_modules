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
}
