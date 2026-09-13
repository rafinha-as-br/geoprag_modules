import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/produto.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/produto_repository.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/presentation/cadastro_formula_screen.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/presentation/criar_formula_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockProdutoRepository extends Mock implements ProdutoRepository {}

class MockAdminNavigator extends Mock implements AdminNavigator {}

void main() {
  late MockProdutoRepository repository;
  late MockAdminNavigator navigator;

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

  setUp(() {
    repository = MockProdutoRepository();
    navigator = MockAdminNavigator();
    when(() => repository.listar()).thenAnswer((_) async => [produto]);
  });

  Future<void> montar(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdminNavigatorScope(
          navigator: navigator,
          child: BlocProvider(
            create: (_) => CriarFormulaCubit(repository),
            child: const CadastroFormulaScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    // GEOPRAG-150: as 3 telas de `inventory_and_bidding` compartilham o
    // mesmo dashboard (Estoque) no X, mas cada uma tem seu próprio destino
    // de sucesso (aqui, toEstoqueFormula) — risco real de copiar o alvo
    // errado entre as três.
    'X leva ao dashboard de Estoque, não à listagem de fórmulas do sucesso',
    (tester) async {
      await montar(tester);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      verify(() => navigator.toEstoque()).called(1);
      verifyNever(() => navigator.toEstoqueFormula());
    },
  );
}
