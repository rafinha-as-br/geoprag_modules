import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/core/aplicador_navigator.dart';
import 'package:geoprag_modules/aplicador_app/reports/presentation/tela_educativa_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAplicadorNavigator extends Mock implements AplicadorNavigator {}

void main() {
  late MockAplicadorNavigator navigator;

  setUp(() {
    navigator = MockAplicadorNavigator();
  });

  Widget wrap() {
    return MaterialApp(
      home: AplicadorNavigatorScope(
        navigator: navigator,
        child: const TelaEducativaScreen(),
      ),
    );
  }

  testWidgets(
    'mostra título, checklist e aciona toDenunciaNova ao avançar',
    (tester) async {
      await tester.pumpWidget(wrap());

      expect(find.text('Antes de denunciar...'), findsOneWidget);
      expect(find.text('O que é um foco de borrachudo?'), findsOneWidget);
      expect(find.text('Entendi, avançar'), findsOneWidget);

      await tester.ensureVisible(find.text('Entendi, avançar'));
      await tester.tap(find.text('Entendi, avançar'));
      verify(() => navigator.toDenunciaNova()).called(1);
    },
  );

  testWidgets('aciona back ao cancelar', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.ensureVisible(find.text('Cancelar'));
    await tester.tap(find.text('Cancelar'));
    verify(() => navigator.back()).called(1);
  });
}
