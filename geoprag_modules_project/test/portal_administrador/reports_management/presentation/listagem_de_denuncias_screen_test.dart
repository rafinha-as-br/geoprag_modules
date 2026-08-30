import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/core/denuncia.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/core/denuncia_repository.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/presentation/listagem_de_denuncias_screen.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/presentation/listagem_denuncias_controller.dart';
import 'package:mocktail/mocktail.dart';

class MockDenunciaRepository extends Mock implements DenunciaRepository {}

class MockAdminNavigator extends Mock implements AdminNavigator {}

void main() {
  testWidgets('busca filtra por denunciante ou descrição', (tester) async {
    final repository = MockDenunciaRepository();
    final navigator = MockAdminNavigator();
    when(() => repository.listar()).thenAnswer(
      (_) async => [
        Denuncia(
          id: 'r1',
          lat: 0,
          lng: 0,
          nivelInfestacao: 'Alto',
          descricao: 'Foco na praça central',
          status: 'Recebida',
          dataHora: DateTime(2026, 7, 5),
          denunciante: 'João Silva',
          observacoes: '',
        ),
        Denuncia(
          id: 'r2',
          lat: 0,
          lng: 0,
          nivelInfestacao: 'Alto',
          descricao: 'Foco na avenida principal',
          status: 'Recebida',
          dataHora: DateTime(2026, 7, 6),
          denunciante: 'Maria Souza',
          observacoes: '',
        ),
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
              BlocProvider(
                create: (_) => ListagemDenunciasController(repository),
              ),
            ],
            child: const ListagemDeDenunciasScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('João Silva'), findsOneWidget);
    expect(find.text('Maria Souza'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'maria');
    await tester.pump();

    expect(find.text('João Silva'), findsNothing);
    expect(find.text('Maria Souza'), findsOneWidget);
  });

  testWidgets(
    'mostra o empty-state quando os filtros não retornam nenhuma denúncia',
    (tester) async {
      final repository = MockDenunciaRepository();
      final navigator = MockAdminNavigator();
      when(() => repository.listar()).thenAnswer((_) async => []);

      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: AdminNavigatorScope(
            navigator: navigator,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => AdminSessionCubit()),
                BlocProvider(
                  create: (_) => ListagemDenunciasController(repository),
                ),
              ],
              child: const ListagemDeDenunciasScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text('Nenhuma denúncia encontrada para os filtros aplicados.'),
        findsOneWidget,
      );
    },
  );
}
