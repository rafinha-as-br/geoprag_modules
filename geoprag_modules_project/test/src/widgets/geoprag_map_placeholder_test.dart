import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/widgets/geoprag_map_placeholder.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('GeopragMapPlaceholder', () {
    testWidgets('mostra a mensagem sem ícone quando icon é nulo', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const GeopragMapPlaceholder(
            message: '[Mapa Interativo]',
            backgroundColor: Colors.green,
            borderColor: Colors.green,
            textColor: Colors.green,
          ),
        ),
      );

      expect(find.text('[Mapa Interativo]'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('mostra o ícone quando icon é informado', (tester) async {
      await tester.pumpWidget(
        wrap(
          const GeopragMapPlaceholder(
            message: '[Mapa Interativo]\nPonto da aplicação',
            backgroundColor: Colors.green,
            borderColor: Colors.green,
            textColor: Colors.green,
            icon: Icons.location_on,
            iconColor: Colors.blue,
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.location_on);
      expect(icon.color, Colors.blue);
    });

    testWidgets('usa textColor como cor do ícone quando iconColor é nulo', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const GeopragMapPlaceholder(
            message: 'placeholder',
            backgroundColor: Colors.blue,
            borderColor: Colors.blue,
            textColor: Colors.blueGrey,
            icon: Icons.map,
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, Colors.blueGrey);
    });

    testWidgets('aplica height fixo quando informado', (tester) async {
      await tester.pumpWidget(
        wrap(
          const GeopragMapPlaceholder(
            message: 'placeholder',
            backgroundColor: Colors.green,
            borderColor: Colors.green,
            textColor: Colors.green,
            height: 260,
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxHeight, 260);
    });
  });
}
