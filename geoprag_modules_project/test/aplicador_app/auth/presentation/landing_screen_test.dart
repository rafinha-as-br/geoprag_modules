import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/auth/presentation/landing_screen.dart';
import 'package:geoprag_modules/aplicador_app/core/aplicador_navigator.dart';
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
        child: const LandingScreen(),
      ),
    );
  }

  testWidgets('mostra boas-vindas e aciona toLogin ao entrar', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    expect(find.text('Bem-vindo(a)!'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);

    await tester.tap(find.text('Entrar'));
    verify(() => navigator.toLogin()).called(1);
  });
}
