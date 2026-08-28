import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/applications/presentation/tela_informativa_screen.dart';
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
        child: const TelaInformativaScreen(),
      ),
    );
  }

  testWidgets('mostra título, explicação e aciona toAplicacaoGeo ao avançar', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    expect(find.text('Registro de Aplicação'), findsOneWidget);
    expect(find.text('Atenção'), findsOneWidget);
    expect(find.text('Estou ciente, continuar'), findsOneWidget);

    await tester.ensureVisible(find.text('Estou ciente, continuar'));
    await tester.tap(find.text('Estou ciente, continuar'));
    verify(() => navigator.toAplicacaoGeo()).called(1);
  });

  testWidgets('aciona back ao cancelar', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.ensureVisible(find.text('Cancelar'));
    await tester.tap(find.text('Cancelar'));
    verify(() => navigator.back()).called(1);
  });
}
