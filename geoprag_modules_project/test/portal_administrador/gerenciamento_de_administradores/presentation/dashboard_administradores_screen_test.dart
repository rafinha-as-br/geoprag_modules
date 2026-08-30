import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/core/administrador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/administradores_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/dashboard_administradores_screen.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/solicitacoes_promocao_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAdministradorRepository extends Mock
    implements AdministradorRepository {}

class MockAdminNavigator extends Mock implements AdminNavigator {}

void main() {
  final contaAdmin = AdminAccount(
    email: 'admin@gaspar.sc.gov.br',
    nome: 'Marcos Vieira',
    cpf: '123.456.789-00',
    dataNascimento: DateTime(1980, 5, 12),
    sexo: 'Masculino',
    dataCriacao: DateTime(2026, 1, 1),
    role: AdminRole.administrador,
  );
  final contaSub = AdminAccount(
    email: 'sub@gaspar.sc.gov.br',
    nome: 'Célia Ramos',
    cpf: '987.654.321-00',
    dataNascimento: DateTime(1990, 3, 20),
    sexo: 'Feminino',
    dataCriacao: DateTime(2026, 1, 1),
    role: AdminRole.subAdministrador,
  );

  testWidgets(
    'renderiza as colunas, filtra pela busca e abre o dialog de detalhes',
    (tester) async {
      final repository = MockAdministradorRepository();
      final navigator = MockAdminNavigator();
      when(
        () => repository.listar(),
      ).thenAnswer((_) async => [contaAdmin, contaSub]);
      when(
        () => repository.listarSolicitacoesAbertas(),
      ).thenAnswer((_) async => []);

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
                  create: (_) => AdministradoresCubit(repository),
                ),
                BlocProvider(
                  create: (_) => SolicitacoesPromocaoCubit(
                    repository,
                    contaAdmin.email,
                  ),
                ),
              ],
              child: const DashboardAdministradoresScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Marcos Vieira'), findsOneWidget);
      expect(find.text('Célia Ramos'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'célia');
      await tester.pump();

      expect(find.text('Marcos Vieira'), findsNothing);
      expect(find.text('Célia Ramos'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();

      expect(find.text('sub@gaspar.sc.gov.br'), findsWidgets);
    },
  );
}
