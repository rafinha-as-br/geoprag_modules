import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_auth_repository.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_esqueci_senha_cubit.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/esqueci_senha_web_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminAuthRepository extends Mock implements AdminAuthRepository {}

class MockAdminNavigator extends Mock implements AdminNavigator {}

void main() {
  testWidgets(
    'valida o e-mail obrigatório e aciona o Cubit quando preenchido',
    (tester) async {
      final repository = MockAdminAuthRepository();
      final navigator = MockAdminNavigator();
      when(
        () => repository.findByEmail(any()),
      ).thenAnswer((_) => Completer<AdminAccount?>().future);

      await tester.pumpWidget(
        MaterialApp(
          home: AdminNavigatorScope(
            navigator: navigator,
            child: BlocProvider(
              create: (_) => AdminEsqueciSenhaCubit(repository),
              child: const EsqueciSenhaWebScreen(),
            ),
          ),
        ),
      );

      final button = find.widgetWithText(ElevatedButton, 'Solicitar redefinição');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
      expect(
        find.text('Informe o e-mail institucional cadastrado'),
        findsOneWidget,
      );
      verifyNever(() => repository.findByEmail(any()));

      await tester.enterText(
        find.byType(TextFormField),
        'admin@gaspar.sc.gov.br',
      );
      await tester.ensureVisible(button);
      await tester.tap(button);

      verify(() => repository.findByEmail('admin@gaspar.sc.gov.br')).called(1);
    },
  );

  testWidgets('"Voltar ao login" aciona o navigator.back()', (tester) async {
    final repository = MockAdminAuthRepository();
    final navigator = MockAdminNavigator();

    await tester.pumpWidget(
      MaterialApp(
        home: AdminNavigatorScope(
          navigator: navigator,
          child: BlocProvider(
            create: (_) => AdminEsqueciSenhaCubit(repository),
            child: const EsqueciSenhaWebScreen(),
          ),
        ),
      ),
    );

    final voltar = find.text('Voltar ao login');
    await tester.ensureVisible(voltar);
    await tester.tap(voltar);
    verify(() => navigator.back()).called(1);
  });
}
