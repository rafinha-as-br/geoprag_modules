import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/widgets/acesso_negado_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminNavigator extends Mock implements AdminNavigator {}

void main() {
  late MockAdminNavigator navigator;

  final conta = AdminAccount(
    email: 'admin@gaspar.sc.gov.br',
    nome: 'Marcos Vieira',
    cpf: '123.456.789-00',
    dataNascimento: DateTime(1980, 5, 12),
    sexo: 'Masculino',
    dataCriacao: DateTime(2026, 1, 1),
    role: AdminRole.administrador,
  );

  setUp(() {
    navigator = MockAdminNavigator();
  });

  // AdminScaffold renderiza o SidebarMenu, que lê AdminSessionCubit do
  // context — precisa estar provido mesmo numa tela de acesso negado
  // (a sessão continua autenticada, só falta a capacidade/módulo).
  Widget wrap(Widget child) => MaterialApp(
    home: AdminNavigatorScope(
      navigator: navigator,
      child: BlocProvider(
        create: (_) => AdminSessionCubit()..iniciarSessao(conta),
        child: child,
      ),
    ),
  );

  testWidgets('mostra a mensagem e volta ao dashboard ao clicar', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const AcessoNegadoScreen(
          currentRoute: '/estoque',
          mensagem: 'Este módulo é restrito ao Administrador.',
        ),
      ),
    );

    expect(find.text('Acesso negado'), findsOneWidget);
    expect(
      find.text('Este módulo é restrito ao Administrador.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Voltar ao início'));
    verify(() => navigator.toDashboard()).called(1);
  });

  testWidgets('usa a mensagem padrão quando nenhuma é informada', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const AcessoNegadoScreen(currentRoute: '/estoque')),
    );

    expect(
      find.text('Seu cargo não tem acesso a este módulo.'),
      findsOneWidget,
    );
  });
}
