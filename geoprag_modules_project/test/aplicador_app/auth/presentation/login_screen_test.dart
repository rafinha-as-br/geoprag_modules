import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/auth/core/auth_repository.dart';
import 'package:geoprag_modules/aplicador_app/auth/presentation/login_cubit.dart';
import 'package:geoprag_modules/aplicador_app/auth/presentation/login_screen.dart';
import 'package:geoprag_modules/aplicador_app/auth/core/usuario.dart';
import 'package:geoprag_modules/aplicador_app/core/aplicador_navigator.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAplicadorNavigator extends Mock implements AplicadorNavigator {}

void main() {
  testWidgets(
    'renderiza os campos e aciona o LoginCubit com os valores digitados',
    (tester) async {
      final repository = MockAuthRepository();
      final navigator = MockAplicadorNavigator();
      when(
        () => repository.login(
          identifier: any(named: 'identifier'),
          senha: any(named: 'senha'),
        ),
      ).thenAnswer((_) => Completer<Usuario>().future);

      await tester.pumpWidget(
        MaterialApp(
          home: AplicadorNavigatorScope(
            navigator: navigator,
            child: BlocProvider(
              create: (_) => LoginCubit(repository),
              child: const LoginScreen(),
            ),
          ),
        ),
      );

      expect(find.text('Entrar'), findsWidgets);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'CPF ou E-mail'),
        '12345678900',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'minhasenha',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));

      verify(
        () => repository.login(identifier: '12345678900', senha: 'minhasenha'),
      ).called(1);
    },
  );
}
