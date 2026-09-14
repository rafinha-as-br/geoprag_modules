import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_state.dart';
import 'package:geoprag_modules/portal_administrador/widgets/sidebar_menu.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminNavigator extends Mock implements AdminNavigator {}

/// Aciona o `onTap` do botão de conta sem simular o gesto de toque
/// completo — `tester.tap()` dispara o efeito de ripple do `InkWell`, que
/// tenta carregar o shader `ink_sparkle.frag`, indisponível no ambiente
/// deste runner de testes (falha de todo `tester.tap()` sobre `InkWell`
/// neste ambiente, não específica deste widget). Chamar o callback
/// diretamente testa a mesma lógica de abrir/fechar o menu sem depender do
/// pipeline de renderização do splash.
Future<void> _tocarNoBotaoDeConta(WidgetTester tester) async {
  final inkWell = tester.widget<InkWell>(
    find.byKey(const Key('sidebar_conta_footer_botao')),
  );
  inkWell.onTap!();
  await tester.pump();
}

void main() {
  final contaAdmin = AdminAccount(
    email: 'admin@gaspar.sc.gov.br',
    nome: 'Marcos Vieira',
    cpf: '123.456.789-00',
    dataNascimento: DateTime(1980, 5, 12),
    sexo: 'Masculino',
    dataCriacao: DateTime(2026, 1, 1),
    role: AdminRole.administrador,
  );

  late MockAdminNavigator navigator;
  late AdminSessionCubit sessionCubit;

  Widget wrap() {
    return MaterialApp(
      home: AdminNavigatorScope(
        navigator: navigator,
        child: BlocProvider.value(
          value: sessionCubit,
          child: const Scaffold(
            body: SidebarMenu(currentRoute: '/dashboard'),
          ),
        ),
      ),
    );
  }

  setUp(() {
    navigator = MockAdminNavigator();
    sessionCubit = AdminSessionCubit()..iniciarSessao(contaAdmin);
  });

  testWidgets('mostra nome e cargo do administrador logado no rodapé', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    expect(find.text('Marcos Vieira'), findsOneWidget);
    expect(find.text('Administrador'), findsOneWidget);
    // O ListTile "Sair" solto de antes não existe mais como item avulso.
    expect(find.widgetWithText(ListTile, 'Sair'), findsNothing);
  });

  testWidgets('abre o menu para cima ao tocar no rodapé e mostra Sair da conta', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    expect(find.text('Sair da conta'), findsNothing);

    await _tocarNoBotaoDeConta(tester);

    expect(find.text('Sair da conta'), findsOneWidget);
  });

  testWidgets('Sair da conta encerra a sessão e navega para logout', (
    tester,
  ) async {
    when(() => navigator.toLogout()).thenReturn(null);
    await tester.pumpWidget(wrap());

    await _tocarNoBotaoDeConta(tester);
    // Mesmo motivo do `_tocarNoBotaoDeConta`: aciona o callback do item de
    // menu direto, sem depender do splash de `MenuItemButton`.
    final itemSair = tester.widget<MenuItemButton>(
      find.widgetWithText(MenuItemButton, 'Sair da conta'),
    );
    itemSair.onPressed!();
    await tester.pump();

    expect(sessionCubit.state, isA<AdminSessionSemAcesso>());
    verify(() => navigator.toLogout()).called(1);
  });

  testWidgets('mostra as iniciais do nome no avatar do rodapé', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    expect(find.text('MV'), findsOneWidget);
  });
}
