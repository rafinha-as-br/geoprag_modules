import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/produto.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/produto_repository.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/presentation/produtos_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockProdutoRepository extends Mock implements ProdutoRepository {}

void main() {
  late MockProdutoRepository repository;

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

  setUp(() {
    repository = MockProdutoRepository();
  });

  test('carrega os produtos mapeados para ViewModel', () async {
    when(() => repository.listar()).thenAnswer((_) async => [produto]);

    final cubit = ProdutosCubit(repository);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.items.single.nome, 'BTI Líquido');
    expect(cubit.state.isLoading, isFalse);
  });

  test(
    'emite mensagem amigável quando o repositório falha '
    '(nunca expõe a exceção bruta ao usuário)',
    () async {
      when(
        () => repository.listar(),
      ).thenAnswer((_) async => throw Exception('offline'));

      final cubit = ProdutosCubit(repository);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.errorMessage, isNot(contains('Exception')));
    },
  );

  test('busca filtra por nome, lote ou licitação', () async {
    final outroProduto = Produto(
      id: 'p2',
      nome: 'Larvicida Granulado',
      lote: 'L-002',
      dataValidade: DateTime(2026, 12, 1),
      status: 'Produto em estoque',
      quantidade: 30,
      quantidadeOriginal: 500,
      unidadeMedida: 'Kg',
      licitacao: 'Pregão 02/2026',
      fornecedor: 'BioInsumos Ltda.',
    );
    when(
      () => repository.listar(),
    ).thenAnswer((_) async => [produto, outroProduto]);

    final cubit = ProdutosCubit(repository);
    await Future<void>.delayed(Duration.zero);

    cubit.buscar('granulado');

    expect(cubit.state.items.single.nome, 'Larvicida Granulado');
  });
}
