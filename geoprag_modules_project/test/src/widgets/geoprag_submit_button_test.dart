import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/widgets/geoprag_submit_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('GeopragSubmitButton', () {
    testWidgets('mostra o label e chama onPressed quando não está carregando', (
      tester,
    ) async {
      var pressed = false;

      await tester.pumpWidget(
        wrap(
          GeopragSubmitButton(
            label: 'Entrar',
            isLoading: false,
            onPressed: () => pressed = true,
          ),
        ),
      );

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isTrue);
    });

    testWidgets('mostra spinner e desabilita o botão quando isLoading é true', (
      tester,
    ) async {
      var pressed = false;

      await tester.pumpWidget(
        wrap(
          GeopragSubmitButton(
            label: 'Entrar',
            isLoading: true,
            onPressed: () => pressed = true,
          ),
        ),
      );

      expect(find.text('Entrar'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      expect(pressed, isFalse);
    });

    testWidgets('aplica style e labelStyle customizados', (tester) async {
      await tester.pumpWidget(
        wrap(
          GeopragSubmitButton(
            label: 'Entrar no Portal',
            isLoading: false,
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
            ),
            labelStyle: const TextStyle(fontSize: 18),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Entrar no Portal'));
      expect(text.style?.fontSize, 18);

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.style, isNotNull);
    });
  });
}
