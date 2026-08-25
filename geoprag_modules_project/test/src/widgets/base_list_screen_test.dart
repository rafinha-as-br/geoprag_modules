import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/widgets/geoprag_data_table.dart';
import 'package:geoprag_modules/src/state/acao_feedback.dart';
import 'package:geoprag_modules/src/theme/geoprag_colors.dart';
import 'package:geoprag_modules/src/widgets/base_list_screen.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: BlocProvider(create: (_) => AdminSessionCubit(), child: child),
  );

  List<GeopragDataColumn<String>> colunas() => [
    GeopragDataColumn<String>(
      label: 'Nome',
      width: const FlexColumnWidth(1),
      cellBuilder: (context, item) => Text(item),
    ),
  ];

  BaseListScreen<String> screen({
    bool isLoading = false,
    String? errorMessage,
    String Function(String message)? errorMessageBuilder,
    List<String>? items = const [],
    List<Widget> actions = const [],
    AcaoFeedback? feedback,
  }) => BaseListScreen<String>(
    currentRoute: '/aplicadores',
    appBarTitle: 'Gerenciamento de Aplicadores',
    title: 'Voluntários Cadastrados',
    actions: actions,
    filterBar: const TextField(key: Key('filter-bar')),
    isLoading: isLoading,
    errorMessage: errorMessage,
    entityLabel: 'os aplicadores',
    errorMessageBuilder: errorMessageBuilder,
    items: items,
    columns: colunas(),
    emptyStateBuilder: (context) => const Text('Nenhum aplicador encontrado.'),
    feedback: feedback,
  );

  group('BaseListScreen', () {
    testWidgets('monta AdminScaffold com o título do AppBar', (tester) async {
      await tester.pumpWidget(wrap(screen()));

      expect(find.widgetWithText(AppBar, 'Gerenciamento de Aplicadores'), findsOneWidget);
    });

    testWidgets('título principal usa fontSize 28 e fontWeight bold', (tester) async {
      await tester.pumpWidget(wrap(screen()));

      final titleText = tester.widget<Text>(find.text('Voluntários Cadastrados'));
      expect(titleText.style?.fontSize, 28);
      expect(titleText.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('sempre renderiza o filterBar informado', (tester) async {
      await tester.pumpWidget(wrap(screen()));

      expect(find.byKey(const Key('filter-bar')), findsOneWidget);
    });

    testWidgets('renderiza as actions quando informadas', (tester) async {
      await tester.pumpWidget(
        wrap(
          screen(
            actions: [ElevatedButton(onPressed: () {}, child: const Text('Novo Aplicador'))],
          ),
        ),
      );

      expect(find.text('Novo Aplicador'), findsOneWidget);
    });

    testWidgets('não renderiza ElevatedButton quando actions está vazia', (tester) async {
      await tester.pumpWidget(wrap(screen()));

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('mostra spinner quando isLoading é true, sem tabela', (tester) async {
      await tester.pumpWidget(wrap(screen(isLoading: true, items: null)));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(GeopragDataTable<String>), findsNothing);
    });

    testWidgets(
      'mostra a mensagem-padrão "Não foi possível carregar <entityLabel>: <message>" no erro',
      (tester) async {
        await tester.pumpWidget(wrap(screen(errorMessage: 'falha de rede', items: null)));

        expect(find.text('Não foi possível carregar os aplicadores: falha de rede'), findsOneWidget);
      },
    );

    testWidgets('permite sobrescrever a mensagem de erro via errorMessageBuilder', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          screen(
            errorMessage: 'timeout',
            errorMessageBuilder: (message) => 'Falha customizada: $message',
            items: null,
          ),
        ),
      );

      expect(find.text('Falha customizada: timeout'), findsOneWidget);
      expect(
        find.text('Não foi possível carregar os aplicadores: timeout'),
        findsNothing,
      );
    });

    testWidgets('mostra o empty-state obrigatório quando items está vazio', (tester) async {
      await tester.pumpWidget(wrap(screen(items: const [])));

      expect(find.text('Nenhum aplicador encontrado.'), findsOneWidget);
      expect(find.byType(GeopragDataTable<String>), findsNothing);
    });

    testWidgets('renderiza GeopragDataTable com os items quando há dados', (tester) async {
      await tester.pumpWidget(wrap(screen(items: const ['Item A', 'Item B'])));

      expect(find.byType(GeopragDataTable<String>), findsOneWidget);
      expect(find.text('Item A'), findsOneWidget);
      expect(find.text('Item B'), findsOneWidget);
    });

    testWidgets('mostra SnackBar verde ao receber AcaoFeedbackSucesso', (tester) async {
      await tester.pumpWidget(wrap(screen()));
      await tester.pumpWidget(
        wrap(screen(feedback: const AcaoFeedbackSucesso('Aplicador ativado com sucesso.'))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aplicador ativado com sucesso.'), findsOneWidget);
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, GeopragColors.statusEmDia);
    });

    testWidgets('mostra SnackBar vermelho ao receber AcaoFeedbackErro', (tester) async {
      await tester.pumpWidget(wrap(screen()));
      await tester.pumpWidget(
        wrap(screen(feedback: const AcaoFeedbackErro('Não foi possível ativar o aplicador.'))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível ativar o aplicador.'), findsOneWidget);
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, GeopragColors.statusAtrasado);
    });

    testWidgets('não mostra SnackBar quando feedback é null desde o início', (tester) async {
      await tester.pumpWidget(wrap(screen()));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
