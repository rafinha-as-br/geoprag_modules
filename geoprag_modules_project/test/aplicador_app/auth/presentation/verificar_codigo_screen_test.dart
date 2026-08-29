import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/auth/core/auth_repository.dart';
import 'package:geoprag_modules/aplicador_app/auth/presentation/verificar_codigo_cubit.dart';
import 'package:geoprag_modules/aplicador_app/auth/presentation/verificar_codigo_screen.dart';
import 'package:geoprag_modules/aplicador_app/core/aplicador_navigator.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAplicadorNavigator extends Mock implements AplicadorNavigator {}

void main() {
  late MockAuthRepository repository;
  late MockAplicadorNavigator navigator;

  setUp(() {
    repository = MockAuthRepository();
    navigator = MockAplicadorNavigator();
  });

  Widget wrap() {
    return MaterialApp(
      home: AplicadorNavigatorScope(
        navigator: navigator,
        child: BlocProvider(
          create: (_) => VerificarCodigoCubit(repository),
          child: const VerificarCodigoScreen(),
        ),
      ),
    );
  }

  Future<void> preencherCodigo(WidgetTester tester) async {
    final campos = find.byType(TextField);
    for (var i = 0; i < 6; i++) {
      await tester.enterText(campos.at(i), '${i + 1}');
    }
    await tester.pump();
  }

  testWidgets(
    'ramo normal: botão "Confirmar código" habilita só com os 6 dígitos e aciona o Cubit',
    (tester) async {
      when(
        () => repository.verifyResetCode(code: any(named: 'code')),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(wrap());

      final button = find.widgetWithText(ElevatedButton, 'Confirmar código');
      expect(button, findsOneWidget);
      expect(tester.widget<ElevatedButton>(button).onPressed, isNull);

      await preencherCodigo(tester);

      expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);

      await tester.tap(button);
      verify(() => repository.verifyResetCode(code: '123456')).called(1);
    },
  );

  testWidgets(
    'ao expirar (1ª vez): botão vira "Reenviar código" e reinicia o formulário',
    (tester) async {
      await tester.pumpWidget(wrap());

      await tester.pump(const Duration(minutes: 15));

      final reenviar = find.widgetWithText(
        ElevatedButton,
        'Reenviar código (2ª tentativa)',
      );
      expect(reenviar, findsOneWidget);
      expect(find.text('Código expirado.'), findsOneWidget);

      await tester.tap(reenviar);
      await tester.pump();

      expect(find.text('Reenviar código (2ª tentativa)'), findsNothing);
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Confirmar código'),
            )
            .onPressed,
        isNull,
      );
    },
  );

  testWidgets(
    'ao expirar pela 2ª vez: fica bloqueado e o botão vira "Voltar ao login"',
    (tester) async {
      await tester.pumpWidget(wrap());

      await tester.pump(const Duration(minutes: 15));
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Reenviar código (2ª tentativa)'),
      );
      await tester.pump();

      await tester.pump(const Duration(minutes: 15));

      expect(
        find.text('Não será possível redefinir a senha pelas próximas 24 horas.'),
        findsOneWidget,
      );
      final voltar = find.widgetWithText(ElevatedButton, 'Voltar ao login');
      expect(voltar, findsOneWidget);

      await tester.tap(voltar);
      verify(() => navigator.toLoginResetStack()).called(1);
    },
  );
}
