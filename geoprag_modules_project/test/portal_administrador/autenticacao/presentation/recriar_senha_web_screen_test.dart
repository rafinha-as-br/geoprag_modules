import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_auth_repository.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_recriar_senha_cubit.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/recriar_senha_web_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminAuthRepository extends Mock implements AdminAuthRepository {}

class MockAdminNavigator extends Mock implements AdminNavigator {}

void main() {
  testWidgets(
    'aciona o Cubit só quando as senhas coincidem e atendem os requisitos',
    (tester) async {
      final repository = MockAdminAuthRepository();
      final navigator = MockAdminNavigator();
      when(
        () => repository.resetPassword(novaSenha: any(named: 'novaSenha')),
      ).thenAnswer((_) => Completer<void>().future);

      await tester.pumpWidget(
        MaterialApp(
          home: AdminNavigatorScope(
            navigator: navigator,
            child: BlocProvider(
              create: (_) => AdminRecriarSenhaCubit(repository),
              child: const RecriarSenhaWebScreen(),
            ),
          ),
        ),
      );

      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), 'SenhaForte123');
      await tester.enterText(campos.at(1), 'SenhaDiferente999');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pump();
      verifyNever(
        () => repository.resetPassword(novaSenha: any(named: 'novaSenha')),
      );

      await tester.enterText(campos.at(1), 'SenhaForte123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));

      verify(
        () => repository.resetPassword(novaSenha: 'SenhaForte123'),
      ).called(1);
    },
  );
}
