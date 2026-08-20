import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/core/aplicador_navigator.dart';
import 'package:geoprag_modules/src/widgets/aplicador_bottom_nav.dart';
import 'package:mocktail/mocktail.dart';

class MockAplicadorNavigator extends Mock implements AplicadorNavigator {}

void main() {
  late MockAplicadorNavigator navigator;

  Widget wrap(Widget child) {
    return MaterialApp(
      home: AplicadorNavigatorScope(
        navigator: navigator,
        child: Scaffold(bottomNavigationBar: child),
      ),
    );
  }

  setUp(() {
    navigator = MockAplicadorNavigator();
  });

  group('AplicadorBottomNav', () {
    testWidgets('mostra os 3 itens com currentIndex selecionado', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const AplicadorBottomNav(currentIndex: 1)));

      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNav.currentIndex, 1);
      expect(bottomNav.items, hasLength(3));
      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Insumos'), findsOneWidget);
      expect(find.text('Denúncias'), findsOneWidget);
    });

    testWidgets('navega para Ponto ao tocar no índice 0', (tester) async {
      await tester.pumpWidget(wrap(const AplicadorBottomNav(currentIndex: 1)));

      await tester.tap(find.text('Início'));
      verify(() => navigator.toPonto()).called(1);
    });

    testWidgets('navega para Inventário ao tocar no índice 1', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const AplicadorBottomNav(currentIndex: 0)));

      await tester.tap(find.text('Insumos'));
      verify(() => navigator.toInventario()).called(1);
    });

    testWidgets('navega para Denúncias ao tocar no índice 2', (tester) async {
      await tester.pumpWidget(wrap(const AplicadorBottomNav(currentIndex: 0)));

      await tester.tap(find.text('Denúncias'));
      verify(() => navigator.toDenuncias()).called(1);
    });

    testWidgets('não navega ao tocar na aba já selecionada', (tester) async {
      await tester.pumpWidget(wrap(const AplicadorBottomNav(currentIndex: 0)));

      await tester.tap(find.text('Início'));
      verifyNever(() => navigator.toPonto());
    });
  });
}
