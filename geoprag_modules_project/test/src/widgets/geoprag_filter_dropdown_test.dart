import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/widgets/geoprag_filter_dropdown.dart';

void main() {
  testWidgets(
    'mostra o valor inicial e aciona onChanged ao selecionar uma opção',
    (tester) async {
      String? recebido;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GeopragFilterDropdown(
              label: 'Status',
              options: const ['Todas', 'Recebida', 'Resolvido'],
              initialValue: 'Todas',
              onChanged: (value) => recebido = value,
            ),
          ),
        ),
      );

      expect(find.text('Todas'), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Resolvido').last);
      await tester.pumpAndSettle();

      expect(recebido, 'Resolvido');
      expect(find.text('Resolvido'), findsOneWidget);
    },
  );
}
