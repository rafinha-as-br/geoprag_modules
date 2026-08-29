import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/widgets/geoprag_search_field.dart';

void main() {
  testWidgets('mostra o hintText e aciona onChanged com o texto digitado', (
    tester,
  ) async {
    String? recebido;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GeopragSearchField(
            hintText: 'Buscar...',
            onChanged: (value) => recebido = value,
          ),
        ),
      ),
    );

    expect(find.text('Buscar...'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'maria');

    expect(recebido, 'maria');
  });
}
