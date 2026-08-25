import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/state/acao_feedback.dart';
import 'package:geoprag_modules/src/widgets/base_form_screen.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('BaseFormScreen', () {
    testWidgets('mostra título, fields e botão de envio com submitLabel', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          BaseFormScreen(
            formKey: GlobalKey<FormState>(),
            title: 'Novo cadastro',
            fields: const Text('campos do formulário'),
            onSubmit: () async {},
            submitLabel: 'Salvar',
          ),
        ),
      );

      expect(find.text('Novo cadastro'), findsOneWidget);
      expect(find.text('campos do formulário'), findsOneWidget);
      expect(find.text('Salvar'), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets(
      'envolve em Container(600) + Card(elevation:4, radius:16) por padrão',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            BaseFormScreen(
              formKey: GlobalKey<FormState>(),
              title: 'Novo cadastro',
              fields: const SizedBox.shrink(),
              onSubmit: () async {},
              submitLabel: 'Salvar',
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        expect(container.constraints?.maxWidth, 600);

        final card = tester.widget<Card>(find.byType(Card));
        expect(card.elevation, 4);
        expect(
          (card.shape as RoundedRectangleBorder).borderRadius,
          BorderRadius.circular(16),
        );
      },
    );

    testWidgets('aplica width customizado quando informado', (tester) async {
      await tester.pumpWidget(
        wrap(
          BaseFormScreen(
            formKey: GlobalKey<FormState>(),
            title: 'Novo cadastro',
            fields: const SizedBox.shrink(),
            onSubmit: () async {},
            submitLabel: 'Salvar',
            width: 700,
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, 700);
    });

    testWidgets(
      'não chama onSubmit quando a validação do formulário falha',
      (tester) async {
        var submitted = false;
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          wrap(
            BaseFormScreen(
              formKey: formKey,
              title: 'Novo cadastro',
              fields: TextFormField(
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Obrigatório.' : null,
              ),
              onSubmit: () async => submitted = true,
              submitLabel: 'Salvar',
            ),
          ),
        );

        await tester.tap(find.text('Salvar'));
        await tester.pump();

        expect(submitted, isFalse);
        expect(find.text('Obrigatório.'), findsOneWidget);
      },
    );

    testWidgets(
      'chama onSubmit somente depois que a validação do formulário passa',
      (tester) async {
        var submitted = false;
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          wrap(
            BaseFormScreen(
              formKey: formKey,
              title: 'Novo cadastro',
              fields: TextFormField(
                initialValue: 'preenchido',
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Obrigatório.' : null,
              ),
              onSubmit: () async => submitted = true,
              submitLabel: 'Salvar',
            ),
          ),
        );

        await tester.tap(find.text('Salvar'));
        await tester.pump();

        expect(submitted, isTrue);
      },
    );

    testWidgets('mostra spinner e desabilita o botão quando isSubmitting é true', (
      tester,
    ) async {
      var submitted = false;

      await tester.pumpWidget(
        wrap(
          BaseFormScreen(
            formKey: GlobalKey<FormState>(),
            title: 'Novo cadastro',
            fields: const SizedBox.shrink(),
            onSubmit: () async => submitted = true,
            submitLabel: 'Salvar',
            isSubmitting: true,
          ),
        ),
      );

      expect(find.text('Salvar'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      expect(submitted, isFalse);
    });

    testWidgets(
      'mostra SnackBar verde quando acaoFeedback muda para AcaoFeedbackSucesso',
      (tester) async {
        final formKey = GlobalKey<FormState>();
        AcaoFeedback? feedback;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return wrap(
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(
                        () => feedback = const AcaoFeedbackSucesso(
                          'Cadastro salvo com sucesso.',
                        ),
                      ),
                      child: const Text('disparar sucesso'),
                    ),
                    Expanded(
                      child: BaseFormScreen(
                        formKey: formKey,
                        title: 'Novo cadastro',
                        fields: const SizedBox.shrink(),
                        onSubmit: () async {},
                        submitLabel: 'Salvar',
                        acaoFeedback: feedback,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );

        await tester.tap(find.text('disparar sucesso'));
        await tester.pump();
        await tester.pump();

        expect(find.text('Cadastro salvo com sucesso.'), findsOneWidget);
        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, Colors.green.shade700);
      },
    );

    testWidgets(
      'mostra SnackBar vermelho quando acaoFeedback muda para AcaoFeedbackErro',
      (tester) async {
        final formKey = GlobalKey<FormState>();
        AcaoFeedback? feedback;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return wrap(
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(
                        () => feedback = const AcaoFeedbackErro(
                          'Não foi possível salvar o cadastro.',
                        ),
                      ),
                      child: const Text('disparar erro'),
                    ),
                    Expanded(
                      child: BaseFormScreen(
                        formKey: formKey,
                        title: 'Novo cadastro',
                        fields: const SizedBox.shrink(),
                        onSubmit: () async {},
                        submitLabel: 'Salvar',
                        acaoFeedback: feedback,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );

        await tester.tap(find.text('disparar erro'));
        await tester.pump();
        await tester.pump();

        expect(find.text('Não foi possível salvar o cadastro.'), findsOneWidget);
        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, Colors.red.shade700);
      },
    );

    testWidgets(
      'não mostra SnackBar no build inicial mesmo com acaoFeedback já preenchido',
      (tester) async {
        const feedback = AcaoFeedbackSucesso('Cadastro salvo com sucesso.');

        await tester.pumpWidget(
          wrap(
            BaseFormScreen(
              formKey: GlobalKey<FormState>(),
              title: 'Novo cadastro',
              fields: const SizedBox.shrink(),
              onSubmit: () async {},
              submitLabel: 'Salvar',
              acaoFeedback: feedback,
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(SnackBar), findsNothing);
      },
    );
  });
}
