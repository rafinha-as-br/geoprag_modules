import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/widgets/geoprag_data_table.dart';
import 'package:geoprag_modules/src/state/acao_feedback.dart';
import 'package:geoprag_modules/src/theme/geoprag_colors.dart';
import 'package:geoprag_modules/src/widgets/base_list_screen.dart';
import 'package:geoprag_modules/src/widgets/base_screen_feedback.dart';

BaseListScreenModel<String> _model({
  List<Widget> actions = const [],
  Widget? filter,
  void Function(BuildContext context, String item)? onRowTap,
}) => BaseListScreenModel<String>(
  title: 'Voluntários Cadastrados',
  entityLabel: 'os aplicadores',
  columns: [
    GeopragDataColumn<String>(
      label: 'Nome',
      width: const FlexColumnWidth(1),
      cellBuilder: (context, item) => Text(item),
    ),
  ],
  emptyState: const Text('Nenhum aplicador encontrado.'),
  actions: actions,
  filter: filter,
  onRowTap: onRowTap,
);

/// Controller de teste: exercita exatamente o que o Cubit de uma tela real
/// faz ao estender [BaseListScreenController].
class _AplicadoresController extends BaseListScreenController<String> {
  _AplicadoresController({
    List<Widget> actions = const [],
    Widget? filter,
    void Function(BuildContext context, String item)? onRowTap,
  }) : super(_model(actions: actions, filter: filter, onRowTap: onRowTap));
}

/// Controller cujo model troca a frase padrão de erro.
class _ControllerComErroCustomizado extends BaseListScreenController<String> {
  _ControllerComErroCustomizado()
    : super(
        BaseListScreenModel<String>(
          title: 'Voluntários Cadastrados',
          entityLabel: 'os aplicadores',
          columns: const [],
          emptyState: const SizedBox.shrink(),
          errorTextBuilder: (message) => 'Falha customizada: $message',
        ),
      );
}

void main() {
  Widget wrap(BaseListScreenController<String> controller) => MaterialApp(
    home: Scaffold(
      body: BlocProvider<BaseListScreenController<String>>.value(
        value: controller,
        child: const BaseListScreen<BaseListScreenController<String>, String>(),
      ),
    ),
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

    testWidgets('renderiza o filter quando o model informa um', (tester) async {
      await tester.pumpWidget(
        wrap(
          _AplicadoresController(filter: const TextField(key: Key('filter'))),
        ),
      );

      expect(find.byKey(const Key('filter')), findsOneWidget);
    });

    testWidgets('não renderiza filter quando o model não informa um', (
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

    testWidgets(
      'coloca espaçamento entre duas ou mais actions (GEOPRAG-90: '
      'botões colados no cabeçalho)',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            _AplicadoresController(
              actions: [
                ElevatedButton(onPressed: () {}, child: const Text('A')),
                ElevatedButton(onPressed: () {}, child: const Text('B')),
              ],
            ),
          ),
        );

        expect(find.byType(SizedBox), findsWidgets);
        final left = tester.getTopRight(find.text('A'));
        final right = tester.getTopLeft(find.text('B'));
        expect(right.dx - left.dx, greaterThanOrEqualTo(12));
      },
    );

    testWidgets('nasce carregando, não em empty-state', (tester) async {
      await tester.pumpWidget(wrap(_AplicadoresController()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Nenhum aplicador encontrado.'), findsNothing);
    });

    testWidgets('mostra spinner em emitLoading, sem tabela', (tester) async {
      final controller = _AplicadoresController()..emitLoading();
      await tester.pumpWidget(wrap(controller));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(GeopragDataTable<String>), findsNothing);
    });

    testWidgets(
      'usa a frase padrão "Não foi possível carregar <entityLabel>: <message>"',
      (tester) async {
        final controller = _AplicadoresController()..emitError('falha de rede');
        await tester.pumpWidget(wrap(controller));

        expect(
          find.text('Não foi possível carregar os aplicadores: falha de rede'),
          findsOneWidget,
        );
      },
    );

    testWidgets('errorTextBuilder sobrevive à emissão de novo estado', (
      tester,
    ) async {
      final controller = _ControllerComErroCustomizado()..emitError('timeout');
      await tester.pumpWidget(wrap(controller));

      expect(find.text('Falha customizada: timeout'), findsOneWidget);
    });

    testWidgets('mostra o empty-state obrigatório quando items está vazio', (
      tester,
    ) async {
      final controller = _AplicadoresController()..emitItems(const []);
      await tester.pumpWidget(wrap(controller));

      expect(find.text('Nenhum aplicador encontrado.'), findsOneWidget);
      expect(find.byType(GeopragDataTable<String>), findsNothing);
    });

    testWidgets('renderiza GeopragDataTable com os items quando há dados', (
      tester,
    ) async {
      final controller = _AplicadoresController()
        ..emitItems(const ['Item A', 'Item B']);
      await tester.pumpWidget(wrap(controller));

      expect(find.byType(GeopragDataTable<String>), findsOneWidget);
      expect(find.text('Item A'), findsOneWidget);
      expect(find.text('Item B'), findsOneWidget);
    });

    testWidgets('repassa onRowTap para a tabela', (tester) async {
      String? tocado;
      final controller = _AplicadoresController(
        onRowTap: (context, item) => tocado = item,
      )..emitItems(const ['Item A']);
      await tester.pumpWidget(wrap(controller));

      await tester.tap(find.text('Item A'));

      expect(tocado, 'Item A');
    });

    testWidgets('rerenderiza quando o controller emite novo estado', (
      tester,
    ) async {
      final controller = _AplicadoresController()..emitLoading();
      await tester.pumpWidget(wrap(controller));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      controller.emitItems(const ['Item A']);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Item A'), findsOneWidget);
    });

    testWidgets('emitItems limpa o erro anterior', (tester) async {
      final controller = _AplicadoresController()..emitError('falha de rede');
      await tester.pumpWidget(wrap(controller));
      expect(
        find.text('Não foi possível carregar os aplicadores: falha de rede'),
        findsOneWidget,
      );

      controller.emitItems(const ['Item A']);
      await tester.pump();

      expect(find.textContaining('Não foi possível carregar'), findsNothing);
      expect(find.text('Item A'), findsOneWidget);
    });

    testWidgets('exibe feedback de sucesso na cor de status em dia', (
      tester,
    ) async {
      final controller = _AplicadoresController()
        ..emitFeedback(const AcaoFeedbackSucesso('Aplicador ativado.'));
      await tester.pumpWidget(wrap(controller));

      final texto = tester.widget<Text>(find.text('Aplicador ativado.'));
      expect(texto.style?.color, GeopragColors.statusEmDia);
    });

    testWidgets('exibe feedback de erro na cor de status atrasado', (
      tester,
    ) async {
      final controller = _AplicadoresController()
        ..emitFeedback(const AcaoFeedbackErro('Não foi possível ativar.'));
      await tester.pumpWidget(wrap(controller));

      final texto = tester.widget<Text>(find.text('Não foi possível ativar.'));
      expect(texto.style?.color, GeopragColors.statusAtrasado);
    });

    testWidgets('não exibe feedback quando não há nenhum', (tester) async {
      await tester.pumpWidget(wrap(_AplicadoresController()));

      expect(find.byType(BaseScreenFeedback), findsNothing);
    });

    testWidgets('emitFeedback(null) remove o aviso em cena', (tester) async {
      final controller = _AplicadoresController()
        ..emitFeedback(const AcaoFeedbackSucesso('Aplicador ativado.'));
      await tester.pumpWidget(wrap(controller));
      expect(find.byType(BaseScreenFeedback), findsOneWidget);

      controller.emitFeedback(null);
      await tester.pump();

      expect(find.byType(BaseScreenFeedback), findsNothing);
    });

    testWidgets(
      'emitLoading limpa o feedback de uma ação anterior não relacionada',
      (tester) async {
        final controller = _AplicadoresController()
          ..emitFeedback(const AcaoFeedbackSucesso('Aplicador ativado.'));
        await tester.pumpWidget(wrap(controller));
        expect(find.byType(BaseScreenFeedback), findsOneWidget);

        controller.emitLoading();
        await tester.pump();

        expect(find.byType(BaseScreenFeedback), findsNothing);
      },
    );

    test('items do model é imutável', () {
      final mutavel = ['Item A'];
      final model = _model().copyWith(items: mutavel);

      expect(() => model.items.add('Item B'), throwsUnsupportedError);
    });
  });
}
