import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/state/acao_feedback.dart';
import 'package:geoprag_modules/src/theme/geoprag_colors.dart';
import 'package:geoprag_modules/src/widgets/base_form_screen.dart';
import 'package:geoprag_modules/src/widgets/base_screen_feedback.dart';

/// Controller de teste: exercita exatamente o que o Cubit de uma tela real
/// faz ao estender [BaseFormController].
class _CadastroController extends BaseFormController {
  static final nomeController = TextEditingController();

  int submitCount = 0;
  Object? erroDoSubmit;

  /// Quando informado, [onSubmit] fica pendente até ser completado pelo
  /// teste — permite observar o estado "enviando" em cena.
  Completer<void>? envioPendente;

  _CadastroController({String? description})
    : super(
        BaseFormModel(
          title: 'Novo Produto',
          description: description,
          submitLabel: 'Registrar Produto',
          fields: [
            BaseFormField(
              label: 'Nome do produto',
              field: TextFormField(
                controller: nomeController,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Informe o nome.' : null,
              ),
            ),
          ],
        ),
      );

  @override
  Future<void> onSubmit() async {
    submitCount++;
    if (envioPendente != null) await envioPendente!.future;
    if (erroDoSubmit != null) throw erroDoSubmit!;
  }
}

/// Controller de teste com muitos campos — reproduz um formulário grande o
/// bastante para estourar a altura de um viewport pequeno sem rolagem.
class _ManyFieldsController extends BaseFormController {
  _ManyFieldsController()
    : super(
        BaseFormModel(
          title: 'Novo Aplicador',
          submitLabel: 'Registrar Produto',
          fields: List.generate(
            15,
            (i) => BaseFormField(
              label: 'Campo $i',
              field: TextFormField(key: ValueKey('campo-$i')),
            ),
          ),
        ),
      );

  @override
  Future<void> onSubmit() async {}
}

void main() {
  setUp(() => _CadastroController.nomeController.clear());

  Widget wrap(BaseFormController controller) => MaterialApp(
    home: Scaffold(
      body: BlocProvider<BaseFormController>.value(
        value: controller,
        child: const BaseFormScreen<BaseFormController>(),
      ),
    ),
  );

  group('BaseFormScreen', () {
    testWidgets('renderiza título, rótulo de cada campo e botão de envio', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(_CadastroController()));

      expect(find.text('Novo Produto'), findsOneWidget);
      expect(find.text('Nome do produto'), findsOneWidget);
      expect(find.text('Registrar Produto'), findsOneWidget);
    });

    testWidgets('renderiza a description quando o model informa uma', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(_CadastroController(description: 'Nasce como rascunho.')),
      );

      expect(find.text('Nasce como rascunho.'), findsOneWidget);
    });

    testWidgets('não monta Scaffold nem AppBar — corpo de tela apenas', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(_CadastroController()));

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('não chama onSubmit quando a validação reprova', (
      tester,
    ) async {
      final controller = _CadastroController();
      await tester.pumpWidget(wrap(controller));

      await tester.tap(find.text('Registrar Produto'));
      await tester.pump();

      expect(controller.submitCount, 0);
      expect(find.text('Informe o nome.'), findsOneWidget);
    });

    testWidgets('chama onSubmit quando a validação passa', (tester) async {
      final controller = _CadastroController();
      await tester.pumpWidget(wrap(controller));

      await tester.enterText(find.byType(TextFormField), 'Larvicida');
      await tester.tap(find.text('Registrar Produto'));
      await tester.pumpAndSettle();

      expect(controller.submitCount, 1);
    });

    testWidgets('submit retorna false sem executar onSubmit se reprovar', (
      tester,
    ) async {
      final controller = _CadastroController();
      await tester.pumpWidget(wrap(controller));

      expect(await controller.submit(), isFalse);
      expect(controller.submitCount, 0);
    });

    testWidgets('mostra spinner e desabilita o botão enquanto envia', (
      tester,
    ) async {
      final controller = _CadastroController()
        ..envioPendente = Completer<void>();
      await tester.pumpWidget(wrap(controller));
      await tester.enterText(find.byType(TextFormField), 'Larvicida');

      final envio = controller.submit();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );

      controller.envioPendente!.complete();
      await envio;
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('libera isSubmitting mesmo quando onSubmit lança', (
      tester,
    ) async {
      final controller = _CadastroController()
        ..erroDoSubmit = Exception('rede');
      await tester.pumpWidget(wrap(controller));
      await tester.enterText(find.byType(TextFormField), 'Larvicida');

      await expectLater(controller.submit(), throwsException);
      await tester.pump();

      expect(controller.state.isSubmitting, isFalse);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('limpa o feedback anterior ao iniciar um novo envio', (
      tester,
    ) async {
      final controller = _CadastroController()
        ..envioPendente = Completer<void>()
        ..emitFeedback(const AcaoFeedbackErro('Não foi possível cadastrar.'));
      await tester.pumpWidget(wrap(controller));
      await tester.enterText(find.byType(TextFormField), 'Larvicida');
      expect(find.text('Não foi possível cadastrar.'), findsOneWidget);

      final envio = controller.submit();
      await tester.pump();

      expect(find.text('Não foi possível cadastrar.'), findsNothing);

      controller.envioPendente!.complete();
      await envio;
    });

    testWidgets('exibe feedback de sucesso na cor de status em dia', (
      tester,
    ) async {
      final controller = _CadastroController()
        ..emitFeedback(const AcaoFeedbackSucesso('Produto cadastrado.'));
      await tester.pumpWidget(wrap(controller));

      final texto = tester.widget<Text>(find.text('Produto cadastrado.'));
      expect(texto.style?.color, GeopragColors.statusEmDia);
    });

    testWidgets('exibe feedback de erro na cor de status atrasado', (
      tester,
    ) async {
      final controller = _CadastroController()
        ..emitFeedback(const AcaoFeedbackErro('Não foi possível cadastrar.'));
      await tester.pumpWidget(wrap(controller));

      final texto = tester.widget<Text>(
        find.text('Não foi possível cadastrar.'),
      );
      expect(texto.style?.color, GeopragColors.statusAtrasado);
    });

    testWidgets('não exibe feedback quando não há nenhum', (tester) async {
      await tester.pumpWidget(wrap(_CadastroController()));

      expect(find.byType(BaseScreenFeedback), findsNothing);
    });

    testWidgets('rerenderiza quando o controller emite novo estado', (
      tester,
    ) async {
      final controller = _CadastroController();
      await tester.pumpWidget(wrap(controller));
      expect(find.byType(BaseScreenFeedback), findsNothing);

      controller.emitFeedback(const AcaoFeedbackSucesso('Produto cadastrado.'));
      await tester.pump();

      expect(find.byType(BaseScreenFeedback), findsOneWidget);
    });

    testWidgets('usa a largura declarada pelo model', (tester) async {
      await tester.pumpWidget(wrap(_CadastroController()));

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(BaseFormScreen<BaseFormController>),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(container.constraints?.maxWidth, 600);
    });

    testWidgets(
      'rola verticalmente sem estourar em formulários com muitos campos',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final controller = _ManyFieldsController();
        await tester.pumpWidget(wrap(controller));

        expect(tester.takeException(), isNull);

        await tester.scrollUntilVisible(
          find.text('Registrar Produto'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Registrar Produto'), findsOneWidget);
      },
    );
  });
}
