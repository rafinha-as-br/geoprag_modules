import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/widgets/geoprag_numero_inteiro_input.dart';

void main() {
  final formKey = GlobalKey<FormState>();

  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Form(key: formKey, child: child)),
  );

  testWidgets('mostra o valor inicial já formatado', (tester) async {
    await tester.pumpWidget(
      wrap(
        GeopragNumeroInteiroInput(
          label: 'Subpontos por ciclo',
          initialValue: 5,
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('recusa letras e sinais na digitação, mantendo só dígitos', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(GeopragNumeroInteiroInput(label: 'Quantidade', onChanged: (_) {})),
    );

    await tester.enterText(find.byType(TextFormField), 'a1b-2c3');
    await tester.pump();

    expect(find.text('123'), findsOneWidget);
  });

  testWidgets('reprova campo obrigatório vazio', (tester) async {
    await tester.pumpWidget(
      wrap(GeopragNumeroInteiroInput(label: 'Quantidade', onChanged: (_) {})),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();

    expect(find.text('Campo obrigatório.'), findsOneWidget);
  });

  testWidgets('permite campo vazio quando não obrigatório', (tester) async {
    await tester.pumpWidget(
      wrap(
        GeopragNumeroInteiroInput(
          label: 'Quantidade',
          obrigatorio: false,
          onChanged: (_) {},
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('reprova zero e negativo', (tester) async {
    await tester.pumpWidget(
      wrap(GeopragNumeroInteiroInput(label: 'Quantidade', onChanged: (_) {})),
    );

    await tester.enterText(find.byType(TextFormField), '0');
    await tester.pump();

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Informe um valor maior que zero.'), findsOneWidget);
  });

  testWidgets('aprova valor positivo e devolve o int convertido', (
    tester,
  ) async {
    int? valorRecebido;
    await tester.pumpWidget(
      wrap(
        GeopragNumeroInteiroInput(
          label: 'Quantidade',
          onChanged: (valor) => valorRecebido = valor,
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), '42');
    await tester.pump();

    expect(valorRecebido, 42);
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('rejeita initialValue negativo ou zero em modo debug', (
    tester,
  ) async {
    expect(
      () => GeopragNumeroInteiroInput(
        label: 'Quantidade',
        initialValue: -1,
        onChanged: (_) {},
      ),
      throwsA(isA<AssertionError>()),
    );
  });
}
