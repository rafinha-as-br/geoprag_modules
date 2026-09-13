import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/widgets/geoprag_numero_decimal_input.dart';

void main() {
  final formKey = GlobalKey<FormState>();

  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Form(key: formKey, child: child)),
  );

  testWidgets('mostra o valor inicial com vírgula como separador', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        GeopragNumeroDecimalInput(
          label: 'Vazão',
          initialValue: 1.5,
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('1,5'), findsOneWidget);
  });

  testWidgets(
    'rejeita uma edição que introduz letra ou uma segunda vírgula, mantendo o valor anterior',
    (tester) async {
      await tester.pumpWidget(
        wrap(GeopragNumeroDecimalInput(label: 'Vazão', onChanged: (_) {})),
      );

      await tester.enterText(find.byType(TextFormField), '12,5');
      await tester.pump();
      expect(find.text('12,5'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '12,5a');
      await tester.pump();
      expect(find.text('12,5'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '12,5,');
      await tester.pump();
      expect(find.text('12,5'), findsOneWidget);
    },
  );

  testWidgets(
    'aceita o ponto como separador decimal (teclado numérico de muitos dispositivos produz ponto, não vírgula)',
    (tester) async {
      double? valorRecebido;
      await tester.pumpWidget(
        wrap(
          GeopragNumeroDecimalInput(
            label: 'Vazão',
            onChanged: (valor) => valorRecebido = valor,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '2.5');
      await tester.pump();

      expect(find.text('2.5'), findsOneWidget);
      expect(valorRecebido, 2.5);
    },
  );

  testWidgets('rejeita misturar ponto e vírgula na mesma edição', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(GeopragNumeroDecimalInput(label: 'Vazão', onChanged: (_) {})),
    );

    await tester.enterText(find.byType(TextFormField), '12,5');
    await tester.pump();

    await tester.enterText(find.byType(TextFormField), '12,5.3');
    await tester.pump();
    expect(find.text('12,5'), findsOneWidget);
  });

  testWidgets(
    'reprova texto não numérico (vírgula solta) mesmo quando não obrigatório',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          GeopragNumeroDecimalInput(
            label: 'Vazão',
            obrigatorio: false,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), ',');
      await tester.pump();

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Informe um valor maior que zero.'), findsOneWidget);
    },
  );

  testWidgets('reprova campo obrigatório vazio', (tester) async {
    await tester.pumpWidget(
      wrap(GeopragNumeroDecimalInput(label: 'Vazão', onChanged: (_) {})),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();

    expect(find.text('Campo obrigatório.'), findsOneWidget);
  });

  testWidgets('reprova zero', (tester) async {
    await tester.pumpWidget(
      wrap(GeopragNumeroDecimalInput(label: 'Vazão', onChanged: (_) {})),
    );

    await tester.enterText(find.byType(TextFormField), '0');
    await tester.pump();

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Informe um valor maior que zero.'), findsOneWidget);
  });

  testWidgets('aprova valor com vírgula e devolve o double convertido', (
    tester,
  ) async {
    double? valorRecebido;
    await tester.pumpWidget(
      wrap(
        GeopragNumeroDecimalInput(
          label: 'Vazão',
          onChanged: (valor) => valorRecebido = valor,
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), '2,5');
    await tester.pump();

    expect(valorRecebido, 2.5);
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('desabilita o campo quando enabled é false', (tester) async {
    await tester.pumpWidget(
      wrap(
        GeopragNumeroDecimalInput(
          label: 'Vazão',
          enabled: false,
          onChanged: (_) {},
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enabled, isFalse);
  });

  testWidgets('rejeita initialValue negativo ou zero em modo debug', (
    tester,
  ) async {
    expect(
      () => GeopragNumeroDecimalInput(
        label: 'Vazão',
        initialValue: -1.5,
        onChanged: (_) {},
      ),
      throwsA(isA<AssertionError>()),
    );
  });
}
