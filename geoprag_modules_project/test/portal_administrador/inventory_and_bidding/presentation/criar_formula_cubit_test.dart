import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/formula_dosagem.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/produto.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/produto_repository.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/presentation/criar_formula_cubit.dart';
import 'package:geoprag_modules/src/widgets/base_form_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockProdutoRepository extends Mock implements ProdutoRepository {}

void main() {
  late MockProdutoRepository repository;
  late CriarFormulaCubit cubit;

  final produto = Produto(
    id: 'p1',
    nome: 'BTI Líquido',
    lote: 'L-001',
    dataValidade: DateTime(2027, 1, 1),
    status: 'Produto em estoque',
    quantidade: 50,
    quantidadeOriginal: 1000,
    unidadeMedida: 'Litros',
    licitacao: 'Pregão 01/2026',
    fornecedor: 'BioInsumos Ltda.',
  );

  Widget wrap() => MaterialApp(
    home: Scaffold(
      body: BlocProvider<CriarFormulaCubit>.value(
        value: cubit,
        child: const BaseFormScreen<CriarFormulaCubit>(),
      ),
    ),
  );

  setUp(() {
    repository = MockProdutoRepository();
  });

  Future<void> criarCubitCarregado(WidgetTester tester) async {
    when(() => repository.listar()).thenAnswer((_) async => [produto]);
    cubit = CriarFormulaCubit(repository);
    await tester.pumpWidget(wrap());
    await tester.pump();
  }

  group('CriarFormulaCubit', () {
    testWidgets(
      'nasce com os valores padrão de fábrica pré-preenchidos',
      (tester) async {
        await criarCubitCarregado(tester);

        expect(find.text('1.5'), findsOneWidget);
        expect(find.text('150'), findsOneWidget);
        expect(find.text('1.2'), findsOneWidget);
      },
    );

    testWidgets(
      'submete o formulário e persiste a fórmula de verdade',
      (tester) async {
        when(
          () => repository.criarFormula(
            produtoId: 'p1',
            fatorConversao: 1.5,
            distanciaCarreamento: 150,
            fatorCorrecao: 1.2,
          ),
        ).thenAnswer(
          (_) async => FormulaDosagem(
            id: 'f3',
            produtoId: 'p1',
            produtoNome: 'BTI Líquido',
            fatorConversao: 1.5,
            distanciaCarreamento: 150,
            fatorCorrecao: 1.2,
            atualizadoEm: DateTime(2026, 8, 1),
          ),
        );

        await criarCubitCarregado(tester);
        await tester.binding.setSurfaceSize(const Size(800, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pump();

        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('BTI Líquido - Lote L-001').last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Salvar Nova Fórmula e Atualizar API'));
        await tester.pumpAndSettle();

        expect(find.text('Fórmula salva com sucesso.'), findsOneWidget);
        verify(
          () => repository.criarFormula(
            produtoId: 'p1',
            fatorConversao: 1.5,
            distanciaCarreamento: 150,
            fatorCorrecao: 1.2,
          ),
        ).called(1);
      },
    );

    testWidgets(
      'não submete sem selecionar o produto',
      (tester) async {
        await criarCubitCarregado(tester);
        await tester.binding.setSurfaceSize(const Size(800, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pump();

        await tester.tap(find.text('Salvar Nova Fórmula e Atualizar API'));
        await tester.pump();

        verifyNever(
          () => repository.criarFormula(
            produtoId: any(named: 'produtoId'),
            fatorConversao: any(named: 'fatorConversao'),
            distanciaCarreamento: any(named: 'distanciaCarreamento'),
            fatorCorrecao: any(named: 'fatorCorrecao'),
          ),
        );
        expect(find.text('Selecione o produto.'), findsOneWidget);
      },
    );
  });
}
