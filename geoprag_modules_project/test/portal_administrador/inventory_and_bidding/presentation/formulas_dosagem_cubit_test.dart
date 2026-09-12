import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/formula_dosagem.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/produto_repository.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/presentation/formulas_dosagem_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockProdutoRepository extends Mock implements ProdutoRepository {}

void main() {
  late MockProdutoRepository repository;

  final formula = FormulaDosagem(
    id: 'f1',
    produtoId: 'p1',
    produtoNome: 'BTI Líquido',
    fatorConversao: 1.5,
    distanciaCarreamento: 150,
    fatorCorrecao: 1.2,
    atualizadoEm: DateTime(2026, 6, 1),
  );

  setUp(() {
    repository = MockProdutoRepository();
  });

  test('carrega as fórmulas mapeadas para ViewModel', () async {
    when(
      () => repository.listarFormulas(),
    ).thenAnswer((_) async => [formula]);

    final cubit = FormulasDosagemCubit(repository);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.items.single.produtoNome, 'BTI Líquido');
    expect(cubit.state.isLoading, isFalse);
  });

  test(
    'emite mensagem amigável quando o repositório falha '
    '(nunca expõe a exceção bruta ao usuário)',
    () async {
      when(
        () => repository.listarFormulas(),
      ).thenAnswer((_) async => throw Exception('offline'));

      final cubit = FormulasDosagemCubit(repository);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.errorMessage, isNot(contains('Exception')));
    },
  );
}
