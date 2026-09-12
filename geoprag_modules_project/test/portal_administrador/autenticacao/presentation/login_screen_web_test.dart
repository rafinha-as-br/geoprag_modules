import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_auth_repository.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_login_cubit.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/login_screen_web.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminAuthRepository extends Mock implements AdminAuthRepository {}

class MockAdminNavigator extends Mock implements AdminNavigator {}

void main() {
  testWidgets(
    'renderiza o GeopragSubmitButton e aciona o AdminLoginCubit com os valores digitados',
    (tester) async {
      final repository = MockAdminAuthRepository();
      final navigator = MockAdminNavigator();
      when(
        () => repository.login(
          identifier: any(named: 'identifier'),
          senha: any(named: 'senha'),
        ),
      ).thenAnswer((_) => Completer<AdminAccount>().future);

      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: AdminNavigatorScope(
            navigator: navigator,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => AdminLoginCubit(repository)),
                BlocProvider(create: (_) => AdminSessionCubit()),
              ],
              child: const LoginScreenWeb(),
            ),
          ),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'CPF ou E-mail Institucional'),
        'admin@gaspar.sc.gov.br',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'minhasenha',
      );

      await tester.tap(find.text('Entrar no Portal'));

      verify(
        () => repository.login(
          identifier: 'admin@gaspar.sc.gov.br',
          senha: 'minhasenha',
        ),
      ).called(1);
    },
  );
}
