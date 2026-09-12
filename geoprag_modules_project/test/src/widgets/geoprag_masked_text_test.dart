import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/widgets/geoprag_masked_text.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('mostra o valor mascarado (só início/fim) por padrão', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const GeopragMaskedText(value: '123.456.789-00')),
    );

    expect(find.text('123.456.789-00'), findsNothing);
    expect(find.text('123•••••••••00'), findsOneWidget);
  });

  testWidgets('alterna entre oculto e visível ao tocar no botão', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const GeopragMaskedText(value: '123.456.789-00')),
    );

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();
    expect(find.text('123.456.789-00'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    expect(find.text('123•••••••••00'), findsOneWidget);
  });

  testWidgets('não mascara quando o valor não tem conteúdo suficiente para ocultar', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const GeopragMaskedText(value: '123')));

    expect(find.text('123'), findsOneWidget);
  });
}
