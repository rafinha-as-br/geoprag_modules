import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/widgets/geoprag_kpi_card.dart';

void main() {
  testWidgets('GeopragKpiCard mostra título, valor e ícone com a cor informada', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GeopragKpiCard(
            title: 'Estoque Crítico',
            value: '3 itens',
            icon: Icons.warning,
            color: Colors.orange,
          ),
        ),
      ),
    );

    expect(find.text('Estoque Crítico'), findsOneWidget);
    expect(find.text('3 itens'), findsOneWidget);

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, Icons.warning);
    expect(icon.color, Colors.orange);
  });
}
