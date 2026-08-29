import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/core/denuncia.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/core/denuncia_repository.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/presentation/dashboard_denuncias_admin_screen.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/presentation/triagem_denuncias_controller.dart';
import 'package:mocktail/mocktail.dart';

class MockDenunciaRepository extends Mock implements DenunciaRepository {}

class MockAdminNavigator extends Mock implements AdminNavigator {}

void main() {
  testWidgets(
    'filtro por status mostra só as denúncias com o status selecionado',
    (tester) async {
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
            denunciante: 'João',
            observacoes: '',
          ),
          Denuncia(
            id: 'r2',
            lat: 0,
            lng: 0,
            nivelInfestacao: 'Alto',
            descricao: 'Foco na avenida principal',
            status: 'Resolvido',
            dataHora: DateTime(2026, 7, 6),
            denunciante: 'Maria',
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
                  create: (_) => TriagemDenunciasController(repository),
                ),
              ],
              child: const DashboardDenunciasAdminScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Foco na praça central'), findsOneWidget);
      expect(find.text('Foco na avenida principal'), findsOneWidget);

      await tester.tap(find.text('Filtrar por Status'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Resolvido').last);
      await tester.pumpAndSettle();

      expect(find.text('Foco na praça central'), findsNothing);
      expect(find.text('Foco na avenida principal'), findsOneWidget);
    },
  );

  testWidgets('"Ver listagem completa" navega para a listagem completa', (
    tester,
  ) async {
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
                create: (_) => TriagemDenunciasController(repository),
              ),
            ],
            child: const DashboardDenunciasAdminScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Ver listagem completa'));
    verify(() => navigator.toDenunciasAdminListagem()).called(1);
  });
}
