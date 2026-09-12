import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/produto.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/produto_repository.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/presentation/dashboard_estoque_screen.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/presentation/produtos_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockProdutoRepository extends Mock implements ProdutoRepository {}

class MockAdminNavigator extends Mock implements AdminNavigator {}

void main() {
  Produto produto(String id, String nome, String lote) => Produto(
    id: id,
    nome: nome,
    lote: lote,
    dataValidade: DateTime(2027, 1, 1),
    status: 'Produto em estoque',
    quantidade: 50,
    quantidadeOriginal: 100,
    unidadeMedida: 'Litros',
    licitacao: 'Pregão 01/2026',
    fornecedor: 'BioInsumos Ltda.',
  );

  testWidgets(
    'renderiza a tabela via GeopragDataTable e a busca filtra por nome',
    (tester) async {
      final repository = MockProdutoRepository();
      final navigator = MockAdminNavigator();
      when(
        () => repository.listar(),
      ).thenAnswer(
        (_) async => [
          produto('p1', 'BTI Líquido', 'L-001'),
          produto('p2', 'Larvicida Granulado', 'L-002'),
        ],
      );

      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: AdminNavigatorScope(
            navigator: navigator,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => AdminSessionCubit()),
                BlocProvider(create: (_) => ProdutosCubit(repository)),
              ],
              child: const DashboardEstoqueScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('BTI Líquido'), findsOneWidget);
      expect(find.textContaining('Larvicida Granulado'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'granulado');
      await tester.pump();

      expect(find.textContaining('BTI Líquido'), findsNothing);
      expect(find.textContaining('Larvicida Granulado'), findsOneWidget);
    },
  );
}
