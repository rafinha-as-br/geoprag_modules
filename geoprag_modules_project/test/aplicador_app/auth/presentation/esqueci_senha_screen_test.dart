import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/auth/core/auth_repository.dart';
import 'package:geoprag_modules/aplicador_app/auth/presentation/esqueci_senha_cubit.dart';
import 'package:geoprag_modules/aplicador_app/auth/presentation/esqueci_senha_screen.dart';
import 'package:geoprag_modules/aplicador_app/core/aplicador_navigator.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAplicadorNavigator extends Mock implements AplicadorNavigator {}

void main() {
  testWidgets(
    'valida o e-mail obrigatório e aciona o Cubit quando preenchido',
    (tester) async {
      final repository = MockAuthRepository();
      final navigator = MockAplicadorNavigator();
      when(
        () => repository.requestPasswordReset(email: any(named: 'email')),
      ).thenAnswer((_) => Completer<void>().future);

      await tester.pumpWidget(
        MaterialApp(
          home: AplicadorNavigatorScope(
            navigator: navigator,
            child: BlocProvider(
              create: (_) => EsqueciSenhaCubit(repository),
              child: const EsqueciSenhaScreen(),
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Enviar código'));
      await tester.pump();
      expect(find.text('Informe o e-mail cadastrado'), findsOneWidget);
      verifyNever(
        () => repository.requestPasswordReset(email: any(named: 'email')),
      );

      await tester.enterText(find.byType(TextFormField), 'joao@exemplo.com');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Enviar código'));

      verify(
        () => repository.requestPasswordReset(email: 'joao@exemplo.com'),
      ).called(1);
    },
  );
}
