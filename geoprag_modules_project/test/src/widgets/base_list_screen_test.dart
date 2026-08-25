import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/widgets/geoprag_data_table.dart';
import 'package:geoprag_modules/src/state/acao_feedback.dart';
import 'package:geoprag_modules/src/theme/geoprag_colors.dart';
import 'package:geoprag_modules/src/widgets/base_list_screen.dart';
import 'package:geoprag_modules/src/widgets/base_screen_feedback.dart';

/// Controller de teste: exercita exatamente o que uma tela concreta declara
/// ao estender [BaseListScreenController].
class _AplicadoresController extends BaseListScreenController<String> {
  final List<Widget> _actions;
  final Widget? _filter;
  final void Function(String item)? _onRowTap;

  _AplicadoresController({
    List<Widget> actions = const [],
    Widget? filter,
    void Function(String item)? onRowTap,
  }) : _actions = actions,
       _filter = filter,
       _onRowTap = onRowTap;

  @override
  String get title => 'Voluntários Cadastrados';

  @override
  String get entityLabel => 'os aplicadores';

  @override
  List<Widget> get actions => _actions;

  @override
  Widget? get filter => _filter;

  @override
  void Function(String item)? get onRowTap => _onRowTap;

  @override
  List<GeopragDataColumn<String>> get columns => [
    GeopragDataColumn<String>(
      label: 'Nome',
      width: const FlexColumnWidth(1),
      cellBuilder: (context, item) => Text(item),
    ),
  ];

  @override
  Widget get emptyState => const Text('Nenhum aplicador encontrado.');
}

/// Controller que sobrescreve a frase padrão de erro.
class _ControllerComErroCustomizado extends _AplicadoresController {
  @override
  String errorText(String message) => 'Falha customizada: $message';
}

void main() {
  Widget wrap(BaseListScreenController<String> controller) => MaterialApp(
    home: Scaffold(body: BaseListScreen<String>(controller: controller)),
  );

  group('BaseListScreen', () {
    testWidgets('título principal usa fontSize 28 e fontWeight bold', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(_AplicadoresController()));

      final titleText = tester.widget<Text>(
        find.text('Voluntários Cadastrados'),
      );
      expect(titleText.style?.fontSize, 28);
      expect(titleText.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('não monta Scaffold nem AppBar — corpo de tela apenas', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(_AplicadoresController()));

      // O único Scaffold em cena é o do wrap do teste, não um montado pelo
      // template: rota e AdminScaffold são responsabilidade da tela que
      // compõe este corpo.
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('renderiza o filter quando o controller informa um', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          _AplicadoresController(filter: const TextField(key: Key('filter'))),
        ),
      );

      expect(find.byKey(const Key('filter')), findsOneWidget);
    });

    testWidgets('não renderiza filter quando o controller não informa um', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(_AplicadoresController()));

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('renderiza as actions quando informadas', (tester) async {
      await tester.pumpWidget(
        wrap(
          _AplicadoresController(
            actions: [
              ElevatedButton(onPressed: () {}, child: const Text('Novo')),
            ],
          ),
        ),
      );

      expect(find.text('Novo'), findsOneWidget);
    });

    testWidgets('nasce carregando, não em empty-state', (tester) async {
      await tester.pumpWidget(wrap(_AplicadoresController()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Nenhum aplicador encontrado.'), findsNothing);
    });

    testWidgets('mostra spinner em setLoading, sem tabela', (tester) async {
      final controller = _AplicadoresController()..setLoading();
      await tester.pumpWidget(wrap(controller));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(GeopragDataTable<String>), findsNothing);
    });

    testWidgets(
      'usa a frase padrão "Não foi possível carregar <entityLabel>: <message>"',
      (tester) async {
        final controller = _AplicadoresController()..setError('falha de rede');
        await tester.pumpWidget(wrap(controller));

        expect(
          find.text('Não foi possível carregar os aplicadores: falha de rede'),
          findsOneWidget,
        );
      },
    );

    testWidgets('permite ao controller sobrescrever a frase de erro', (
      tester,
    ) async {
      final controller = _ControllerComErroCustomizado()..setError('timeout');
      await tester.pumpWidget(wrap(controller));

      expect(find.text('Falha customizada: timeout'), findsOneWidget);
    });

    testWidgets('mostra o empty-state obrigatório quando items está vazio', (
      tester,
    ) async {
      final controller = _AplicadoresController()..setItems(const []);
      await tester.pumpWidget(wrap(controller));

      expect(find.text('Nenhum aplicador encontrado.'), findsOneWidget);
      expect(find.byType(GeopragDataTable<String>), findsNothing);
    });

    testWidgets('renderiza GeopragDataTable com os items quando há dados', (
      tester,
    ) async {
      final controller = _AplicadoresController()
        ..setItems(const ['Item A', 'Item B']);
      await tester.pumpWidget(wrap(controller));

      expect(find.byType(GeopragDataTable<String>), findsOneWidget);
      expect(find.text('Item A'), findsOneWidget);
      expect(find.text('Item B'), findsOneWidget);
    });

    testWidgets('repassa onRowTap para a tabela', (tester) async {
      String? tocado;
      final controller = _AplicadoresController(
        onRowTap: (item) => tocado = item,
      )..setItems(const ['Item A']);
      await tester.pumpWidget(wrap(controller));

      await tester.tap(find.text('Item A'));

      expect(tocado, 'Item A');
    });

    testWidgets('rerenderiza quando o controller notifica', (tester) async {
      final controller = _AplicadoresController()..setLoading();
      await tester.pumpWidget(wrap(controller));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      controller.setItems(const ['Item A']);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Item A'), findsOneWidget);
    });

    testWidgets('exibe feedback de sucesso na cor de status em dia', (
      tester,
    ) async {
      final controller = _AplicadoresController()
        ..setFeedback(const AcaoFeedbackSucesso('Aplicador ativado.'));
      await tester.pumpWidget(wrap(controller));

      expect(find.text('Aplicador ativado.'), findsOneWidget);
      final texto = tester.widget<Text>(find.text('Aplicador ativado.'));
      expect(texto.style?.color, GeopragColors.statusEmDia);
    });

    testWidgets('exibe feedback de erro na cor de status atrasado', (
      tester,
    ) async {
      final controller = _AplicadoresController()
        ..setFeedback(const AcaoFeedbackErro('Não foi possível ativar.'));
      await tester.pumpWidget(wrap(controller));

      final texto = tester.widget<Text>(find.text('Não foi possível ativar.'));
      expect(texto.style?.color, GeopragColors.statusAtrasado);
    });

    testWidgets('não exibe feedback quando não há nenhum', (tester) async {
      await tester.pumpWidget(wrap(_AplicadoresController()));

      expect(find.byType(BaseScreenFeedback), findsNothing);
    });

    testWidgets(
      'duas ações com a mesma mensagem continuam sendo exibidas — o feedback '
      'faz parte do estado do controller, não de um disparo pontual',
      (tester) async {
        final controller = _AplicadoresController()
          ..setFeedback(const AcaoFeedbackSucesso('Aplicador ativado.'));
        await tester.pumpWidget(wrap(controller));
        expect(find.text('Aplicador ativado.'), findsOneWidget);

        controller.setFeedback(null);
        await tester.pump();
        expect(find.text('Aplicador ativado.'), findsNothing);

        controller.setFeedback(const AcaoFeedbackSucesso('Aplicador ativado.'));
        await tester.pump();
        expect(find.text('Aplicador ativado.'), findsOneWidget);
      },
    );
  });
}
