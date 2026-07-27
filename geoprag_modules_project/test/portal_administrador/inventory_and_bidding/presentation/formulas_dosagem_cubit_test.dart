import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/formula_dosagem.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/produto_repository.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/presentation/formulas_dosagem_cubit.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/presentation/formulas_dosagem_state.dart';
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

  blocTest<FormulasDosagemCubit, FormulasDosagemState>(
    'emite [Loaded] com as fórmulas mapeadas para ViewModel',
    setUp: () {
      when(() => repository.listarFormulas()).thenAnswer((_) async => [formula]);
    },
    build: () => FormulasDosagemCubit(repository),
    expect: () => [
      isA<FormulasDosagemLoaded>().having(
        (s) => s.formulas.single.produtoNome,
        'formulas.single.produtoNome',
        'BTI Líquido',
      ),
    ],
  );

  blocTest<FormulasDosagemCubit, FormulasDosagemState>(
    'emite [Error] com mensagem amigável quando o repositório falha '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => repository.listarFormulas()).thenThrow(Exception('offline'));
    },
    build: () => FormulasDosagemCubit(repository),
    expect: () => [
      isA<FormulasDosagemError>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );
}
