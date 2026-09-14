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
  late MockAdminAuthRepository repository;
  late MockAdminNavigator navigator;

  setUp(() {
    repository = MockAdminAuthRepository();
    navigator = MockAdminNavigator();
  });

  Future<void> montar(WidgetTester tester) async {
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
  }

  testWidgets(
    'renderiza o GeopragSubmitButton e aciona o AdminLoginCubit com os valores digitados',
    (tester) async {
      when(
        () => repository.login(
          identifier: any(named: 'identifier'),
          senha: any(named: 'senha'),
        ),
      ).thenAnswer((_) => Completer<AdminAccount>().future);

      await montar(tester);

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

  testWidgets(
    // GEOPRAG-143: apertar Enter no campo de senha submete, sem precisar
    // tocar no botão.
    'Enter no campo de senha efetua o login',
    (tester) async {
      when(
        () => repository.login(
          identifier: any(named: 'identifier'),
          senha: any(named: 'senha'),
        ),
      ).thenAnswer((_) => Completer<AdminAccount>().future);

      await montar(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'CPF ou E-mail Institucional'),
        'admin@gaspar.sc.gov.br',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'minhasenha',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);

      verify(
        () => repository.login(
          identifier: 'admin@gaspar.sc.gov.br',
          senha: 'minhasenha',
        ),
      ).called(1);
    },
  );

  testWidgets(
    // GEOPRAG-143: Enter no campo de e-mail só avança o foco — quem
    // submete é o campo de senha.
    'Enter no campo de e-mail move o foco para a senha, sem submeter',
    (tester) async {
      await montar(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'CPF ou E-mail Institucional'),
        'admin@gaspar.sc.gov.br',
      );
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      verifyNever(
        () => repository.login(
          identifier: any(named: 'identifier'),
          senha: any(named: 'senha'),
        ),
      );
      final senhaEditable = tester.widget<EditableText>(
        find.descendant(
          of: find.widgetWithText(TextFormField, 'Senha'),
          matching: find.byType(EditableText),
        ),
      );
      expect(senhaEditable.focusNode.hasFocus, isTrue);
    },
  );

  testWidgets(
    // GEOPRAG-143: campo vazio reprova no Form e não chega a submeter, nos
    // dois caminhos (Enter e botão).
    'campo de senha vazio não submete, por Enter nem pelo botão',
    (tester) async {
      await montar(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'CPF ou E-mail Institucional'),
        'admin@gaspar.sc.gov.br',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.tap(find.text('Entrar no Portal'));
      await tester.pump();

      verifyNever(
        () => repository.login(
          identifier: any(named: 'identifier'),
          senha: any(named: 'senha'),
        ),
      );
      expect(find.text('Informe sua senha.'), findsOneWidget);
    },
  );

  testWidgets(
    // GEOPRAG-143: com o login já em andamento, um segundo Enter não pode
    // disparar uma segunda tentativa.
    'Enter repetido durante o carregamento não dispara um segundo login',
    (tester) async {
      when(
        () => repository.login(
          identifier: any(named: 'identifier'),
          senha: any(named: 'senha'),
        ),
      ).thenAnswer((_) => Completer<AdminAccount>().future);

      await montar(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'CPF ou E-mail Institucional'),
        'admin@gaspar.sc.gov.br',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'minhasenha',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);

      verify(
        () => repository.login(
          identifier: 'admin@gaspar.sc.gov.br',
          senha: 'minhasenha',
        ),
      ).called(1);
    },
  );
}
