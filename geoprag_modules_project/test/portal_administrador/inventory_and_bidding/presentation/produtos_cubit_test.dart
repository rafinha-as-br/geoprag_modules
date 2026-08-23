import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/produto.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/produto_repository.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/presentation/produtos_cubit.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/presentation/produtos_state.dart';
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

  blocTest<ProdutosCubit, ProdutosState>(
    'emite [Loaded] com os produtos mapeados para ViewModel',
    setUp: () {
      when(() => repository.listar()).thenAnswer((_) async => [produto]);
    },
    build: () => ProdutosCubit(repository),
    expect: () => [
      isA<ProdutosLoaded>().having(
        (s) => s.produtos.single.nome,
        'produtos.single.nome',
        'BTI Líquido',
      ),
    ],
  );

  blocTest<ProdutosCubit, ProdutosState>(
    'emite [Error] com mensagem amigável quando o repositório falha '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => repository.listar()).thenAnswer((_) async => throw Exception('offline'));
    },
    build: () => ProdutosCubit(repository),
    expect: () => [
      isA<ProdutosError>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );
}
