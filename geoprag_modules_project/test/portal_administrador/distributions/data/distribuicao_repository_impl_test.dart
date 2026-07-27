import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/distributions/data/distribuicao_repository_impl.dart';
import 'package:geoprag_modules/portal_administrador/distributions/data/mock_distribuicoes.dart';
import 'package:geoprag_modules/portal_administrador/distributions/data/mock_produtos_referencia_distribuicao.dart';
import 'package:geoprag_modules/portal_administrador/distributions/data/mock_responsaveis_referencia_distribuicao.dart';

void main() {
  late DistribuicaoRepositoryImpl repository;

  setUp(() {
    repository = DistribuicaoRepositoryImpl();
  });

  test('listar retorna todas as distribuições mockadas', () async {
    final result = await repository.listar();
    expect(result.length, mockDistribuicoes.length);
  });

  test('buscarPorId retorna a distribuição correspondente', () async {
    final result = await repository.buscarPorId('d1');
    expect(result.id, 'd1');
  });

  test('buscarPorId lança StateError quando o id não existe', () {
    expect(
      () => repository.buscarPorId('inexistente'),
      throwsA(isA<StateError>()),
    );
  });

  test('buscarNomeProduto resolve o nome de exibição de um produto conhecido', () async {
    final result = await repository.buscarNomeProduto('p1');
    expect(result, 'BTI Líquido - Lote L-001');
  });

  test('buscarNomeProduto retorna fallback para produtoId desconhecido', () async {
    final result = await repository.buscarNomeProduto('inexistente');
    expect(result, 'Produto não identificado');
  });

  test('listarProdutosDisponiveis retorna todos os produtos de referência mockados', () async {
    final result = await repository.listarProdutosDisponiveis();
    expect(result.length, mockProdutosReferenciaDistribuicao.length);
  });

  test('listarResponsaveisDisponiveis retorna todos os responsáveis mockados', () async {
    final result = await repository.listarResponsaveisDisponiveis();
    expect(result.length, mockResponsaveisReferenciaDistribuicao.length);
  });
}
