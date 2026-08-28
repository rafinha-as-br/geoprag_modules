import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/widgets/base_auth_step_screen.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: child);

  group('BaseAuthStepScreen', () {
    testWidgets('mostra AppBar com o título quando informado', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          BaseAuthStepScreen(
            title: 'Entrar',
            body: const Text('Campos do formulário'),
            actionLabel: 'Entrar',
            isLoading: false,
            onAction: () {},
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('Entrar')),
        findsOneWidget,
      );
    });

    testWidgets('não mostra AppBar quando title é nulo', (tester) async {
      await tester.pumpWidget(
        wrap(
          BaseAuthStepScreen(
            body: const Text('Campos do formulário'),
            actionLabel: 'Confirmar',
            isLoading: false,
            onAction: () {},
          ),
        ),
      );

      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('renderiza o body informado', (tester) async {
      await tester.pumpWidget(
        wrap(
          BaseAuthStepScreen(
            body: const Text('E-mail cadastrado'),
            actionLabel: 'Enviar código',
            isLoading: false,
            onAction: () {},
          ),
        ),
      );

      expect(find.text('E-mail cadastrado'), findsOneWidget);
    });

    testWidgets('mostra o actionLabel e chama onAction ao tocar no botão', (
      tester,
    ) async {
      var actionCalled = false;

      await tester.pumpWidget(
        wrap(
          BaseAuthStepScreen(
            body: const SizedBox.shrink(),
            actionLabel: 'Confirmar código',
            isLoading: false,
            onAction: () => actionCalled = true,
          ),
        ),
      );

      expect(find.text('Confirmar código'), findsOneWidget);
      await tester.tap(find.text('Confirmar código'));
      expect(actionCalled, isTrue);
    });

    testWidgets('mostra spinner e desabilita o botão quando isLoading é true', (
      tester,
    ) async {
      var actionCalled = false;

      await tester.pumpWidget(
        wrap(
          BaseAuthStepScreen(
            body: const SizedBox.shrink(),
            actionLabel: 'Salvar',
            isLoading: true,
            onAction: () => actionCalled = true,
          ),
        ),
      );

      expect(find.text('Salvar'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      expect(actionCalled, isFalse);
    });

    testWidgets('onAction nulo desabilita o botão mesmo sem loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          BaseAuthStepScreen(
            body: const SizedBox.shrink(),
            actionLabel: 'Confirmar',
            isLoading: false,
            onAction: null,
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
