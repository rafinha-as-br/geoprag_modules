import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/widgets/base_interstitial_screen.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('BaseInterstitialScreen', () {
    testWidgets('mostra ícone, título, body e botão primário', (
      tester,
    ) async {
      var primaryTapped = false;

      await tester.pumpWidget(
        wrap(
          BaseInterstitialScreen(
            icon: Icons.info_outline_rounded,
            iconColor: Colors.blue,
            title: 'Atenção',
            body: const Text('Explicação do processo.'),
            primaryLabel: 'Estou ciente, continuar',
            onPrimary: () => primaryTapped = true,
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.info_outline_rounded);
      expect(icon.color, Colors.blue);
      expect(find.text('Atenção'), findsOneWidget);
      expect(find.text('Explicação do processo.'), findsOneWidget);

      await tester.tap(find.text('Estou ciente, continuar'));
      expect(primaryTapped, isTrue);
    });

    testWidgets(
      'não mostra botão secundário quando secondaryLabel é nulo',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            BaseInterstitialScreen(
              icon: Icons.school_outlined,
              iconColor: Colors.green,
              title: 'Título',
              body: const SizedBox.shrink(),
              primaryLabel: 'Avançar',
              onPrimary: () {},
            ),
          ),
        );

        expect(find.byType(TextButton), findsNothing);
      },
    );

    testWidgets('mostra e aciona o botão secundário quando informado', (
      tester,
    ) async {
      var secondaryTapped = false;

      await tester.pumpWidget(
        wrap(
          BaseInterstitialScreen(
            icon: Icons.school_outlined,
            iconColor: Colors.green,
            title: 'Título',
            body: const SizedBox.shrink(),
            primaryLabel: 'Avançar',
            onPrimary: () {},
            secondaryLabel: 'Cancelar',
            onSecondary: () => secondaryTapped = true,
          ),
        ),
      );

      expect(find.text('Cancelar'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      expect(secondaryTapped, isTrue);
    });
  });
}
