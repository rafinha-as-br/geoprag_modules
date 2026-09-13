import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/widgets/acesso_negado_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminNavigator extends Mock implements AdminNavigator {}

void main() {
  late MockAdminNavigator navigator;

  setUp(() {
    navigator = MockAdminNavigator();
  });

  // O sidebar não é mais parte desta tela (GEOPRAG-116): quem o provê é o
  // ShellRoute que a envolve em produção, então o teste não precisa de
  // AdminSessionCubit nem de nenhum contexto de sessão.
  Widget wrap(Widget child) => MaterialApp(
    home: AdminNavigatorScope(navigator: navigator, child: child),
  );

  testWidgets('mostra a mensagem e volta ao dashboard ao clicar', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const AcessoNegadoScreen(
          mensagem: 'Este módulo é restrito ao Administrador.',
        ),
      ),
    );

    expect(find.text('Acesso negado'), findsOneWidget);
    expect(
      find.text('Este módulo é restrito ao Administrador.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Voltar ao início'));
    verify(() => navigator.toDashboard()).called(1);
  });

  testWidgets('usa a mensagem padrão quando nenhuma é informada', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const AcessoNegadoScreen()));

    expect(
      find.text('Seu cargo não tem acesso a este módulo.'),
      findsOneWidget,
    );
  });
}
