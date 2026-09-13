import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/widgets/gated_action_button.dart';
import 'package:geoprag_modules/src/permissions/capacidade.dart';

// OutlinedButton.icon retorna uma subclasse privada — find.byType(OutlinedButton)
// não casa por tipo exato. byWidgetPredicate com `is` casa a subclasse também.
final _outlinedButtonFinder = find.byWidgetPredicate(
  (widget) => widget is OutlinedButton,
);

void main() {
  final conta = AdminAccount(
    email: 'admin@gaspar.sc.gov.br',
    nome: 'Marcos Vieira',
    cpf: '123.456.789-00',
    dataNascimento: DateTime(1980, 5, 12),
    sexo: 'Masculino',
    dataCriacao: DateTime(2026, 1, 1),
    role: AdminRole.administrador,
  );

  Widget wrap(AdminSessionCubit cubit, Widget child) => MaterialApp(
    home: Scaffold(
      body: BlocProvider.value(value: cubit, child: child),
    ),
  );

  testWidgets('habilitado e clicável quando o cargo tem a capacidade', (
    tester,
  ) async {
    var pressed = false;
    final cubit = AdminSessionCubit()..iniciarSessao(conta);

    await tester.pumpWidget(
      wrap(
        cubit,
        GatedActionButton(
          label: 'Ativar',
          icon: Icons.check,
          capacidade: Capacidade.ativarPontoAplicacao,
          onPressed: () => pressed = true,
        ),
      ),
    );

    final button = tester.widget<OutlinedButton>(_outlinedButtonFinder);
    expect(button.onPressed, isNotNull);
    expect(find.byType(Tooltip), findsNothing);

    await tester.tap(_outlinedButtonFinder);
    expect(pressed, isTrue);
  });

  testWidgets('desabilitado com Tooltip quando o cargo não tem a capacidade', (
    tester,
  ) async {
    final cubit = AdminSessionCubit();

    await tester.pumpWidget(
      wrap(
        cubit,
        GatedActionButton(
          label: 'Ativar',
          icon: Icons.check,
          capacidade: Capacidade.ativarPontoAplicacao,
          onPressed: () {},
        ),
      ),
    );

    final button = tester.widget<OutlinedButton>(_outlinedButtonFinder);
    expect(button.onPressed, isNull);

    final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
    expect(tooltip.message, contains('permissão'));
  });

  testWidgets(
    'desabilitado com Tooltip quando bloqueado por estado, mesmo com permissão',
    (tester) async {
      final cubit = AdminSessionCubit()..iniciarSessao(conta);

      await tester.pumpWidget(
        wrap(
          cubit,
          GatedActionButton(
            label: 'Ativar',
            icon: Icons.check,
            capacidade: Capacidade.ativarPontoAplicacao,
            onPressed: () {},
            desabilitadoPorEstado: true,
            motivoDesabilitadoPorEstado: 'Ponto já está ativo.',
          ),
        ),
      );

      final button = tester.widget<OutlinedButton>(_outlinedButtonFinder);
      expect(button.onPressed, isNull);

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Ponto já está ativo.');
    },
  );
}
