import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_auth_repository.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/verificar_codigo_admin_cubit.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/verificar_codigo_admin_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminAuthRepository extends Mock implements AdminAuthRepository {}

class MockAdminNavigator extends Mock implements AdminNavigator {}

void main() {
  late MockAdminAuthRepository repository;
  late MockAdminNavigator navigator;

  setUp(() {
    repository = MockAdminAuthRepository();
    navigator = MockAdminNavigator();
  });

  Widget wrap() {
    return MaterialApp(
      home: AdminNavigatorScope(
        navigator: navigator,
        child: BlocProvider(
          create: (_) => VerificarCodigoAdminCubit(repository),
          child: const VerificarCodigoAdminScreen(),
        ),
      ),
    );
  }

  testWidgets(
    'botão "Confirmar" habilita só com OTP + CPF completos e aciona o Cubit',
    (tester) async {
      when(
        () => repository.verifyResetCode(code: any(named: 'code')),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(wrap());

      final button = find.widgetWithText(ElevatedButton, 'Confirmar');
      expect(tester.widget<ElevatedButton>(button).onPressed, isNull);

      final otpFields = find.byType(TextField);
      for (var i = 0; i < 6; i++) {
        await tester.enterText(otpFields.at(i), '${i + 1}');
      }
      await tester.enterText(find.byType(TextFormField), '12345678900');
      await tester.pump();

      expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);

      await tester.tap(button);
      verify(() => repository.verifyResetCode(code: '123456')).called(1);
    },
  );

  testWidgets(
    'ao expirar: botão vira "Reiniciar solicitação" e volta para esqueci senha',
    (tester) async {
      await tester.pumpWidget(wrap());

      await tester.pump(const Duration(minutes: 15));

      final reiniciar = find.widgetWithText(
        ElevatedButton,
        'Reiniciar solicitação',
      );
      expect(reiniciar, findsOneWidget);

      await tester.tap(reiniciar);
      verify(() => navigator.toEsqueciSenha()).called(1);
    },
  );
}
