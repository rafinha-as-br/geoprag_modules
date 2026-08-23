import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/widgets/geoprag_log_panel.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: SizedBox(height: 300, child: child)),
  );

  testWidgets('GeopragLogPanel mostra o título e cada log com bullet', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const GeopragLogPanel(
          title: 'Atualizações de Estoque',
          logs: ['Entrada de 10 litros', 'Saída de 2 litros'],
          icon: Icons.inventory_2,
        ),
      ),
    );

    expect(find.text('Atualizações de Estoque'), findsOneWidget);
    expect(find.text('Entrada de 10 litros'), findsOneWidget);
    expect(find.text('Saída de 2 litros'), findsOneWidget);
    expect(find.text('• '), findsNWidgets(2));
  });

  testWidgets('GeopragLogPanel não quebra com lista de logs vazia', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const GeopragLogPanel(
          title: 'Últimas Aplicações',
          logs: [],
          icon: Icons.water_drop,
        ),
      ),
    );

    expect(find.text('Últimas Aplicações'), findsOneWidget);
    expect(find.text('• '), findsNothing);
  });
}
