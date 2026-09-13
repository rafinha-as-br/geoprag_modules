import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/widgets/geoprag_exit_button.dart';

void main() {
  late ValueNotifier<bool> dirty;
  int exitCount = 0;

  setUp(() {
    dirty = ValueNotifier(false);
    exitCount = 0;
  });

  Widget wrap() => MaterialApp(
    home: Scaffold(
      body: GeopragExitButton(isDirty: dirty, onExit: () => exitCount++),
    ),
  );

  testWidgets('sai direto quando o formulário está limpo', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(exitCount, 1);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('pede confirmação quando há alteração não salva', (tester) async {
    dirty.value = true;
    await tester.pumpWidget(wrap());

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(exitCount, 0);
    expect(find.text('Descartar alterações?'), findsOneWidget);
  });

  testWidgets('continuar editando fecha o diálogo sem sair', (tester) async {
    dirty.value = true;
    await tester.pumpWidget(wrap());
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    await tester.tap(find.text('Continuar editando'));
    await tester.pumpAndSettle();

    expect(exitCount, 0);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('descartar e sair chama onExit e fecha o diálogo', (
    tester,
  ) async {
    dirty.value = true;
    await tester.pumpWidget(wrap());
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    await tester.tap(find.text('Descartar e sair'));
    await tester.pumpAndSettle();

    expect(exitCount, 1);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
