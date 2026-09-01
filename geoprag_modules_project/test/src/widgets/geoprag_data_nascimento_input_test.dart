import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/widgets/geoprag_data_nascimento_input.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('GeopragDataNascimentoInput', () {
    testWidgets(
      'abre o date picker sem lançar quando firstDate é posterior a hoje-18 anos '
      '(GEOPRAG-104/105: data de entrega e validade)',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            GeopragDataNascimentoInput(
              value: null,
              onChanged: (_) {},
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            ),
          ),
        );

        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(DatePickerDialog), findsOneWidget);
      },
    );

    testWidgets(
      'mantém o padrão de hoje-18 anos quando firstDate não é sobrescrito (data de nascimento)',
      (tester) async {
        await tester.pumpWidget(
          wrap(GeopragDataNascimentoInput(value: null, onChanged: (_) {})),
        );

        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final anoEsperado = (DateTime.now().year - 18).toString();
        expect(find.textContaining(anoEsperado), findsWidgets);
      },
    );
  });
}
