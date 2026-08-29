import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/auth/core/auth_repository.dart';
import 'package:geoprag_modules/aplicador_app/auth/presentation/recriar_senha_cubit.dart';
import 'package:geoprag_modules/aplicador_app/auth/presentation/recriar_senha_screen.dart';
import 'package:geoprag_modules/aplicador_app/core/aplicador_navigator.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAplicadorNavigator extends Mock implements AplicadorNavigator {}

void main() {
  testWidgets(
    'aciona o Cubit só quando as senhas coincidem e atendem os requisitos',
    (tester) async {
      final repository = MockAuthRepository();
      final navigator = MockAplicadorNavigator();
      when(
        () => repository.resetPassword(novaSenha: any(named: 'novaSenha')),
      ).thenAnswer((_) => Completer<void>().future);

      await tester.pumpWidget(
        MaterialApp(
          home: AplicadorNavigatorScope(
            navigator: navigator,
            child: BlocProvider(
              create: (_) => RecriarSenhaCubit(repository),
              child: const RecriarSenhaScreen(),
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
