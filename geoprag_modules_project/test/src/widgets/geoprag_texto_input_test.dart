import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/widgets/geoprag_texto_input.dart';

void main() {
  final formKey = GlobalKey<FormState>();

  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Form(key: formKey, child: child)),
  );

  testWidgets('mostra o valor inicial', (tester) async {
    await tester.pumpWidget(
      wrap(
        GeopragTextoInput(
          label: 'Descrição do trecho',
          initialValue: 'Rua das Flores',
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Rua das Flores'), findsOneWidget);
  });

  testWidgets('reprova campo obrigatório vazio', (tester) async {
    await tester.pumpWidget(
      wrap(GeopragTextoInput(label: 'Descrição', onChanged: (_) {})),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();

    expect(find.text('Campo obrigatório.'), findsOneWidget);
  });

  testWidgets('permite campo vazio quando não obrigatório', (tester) async {
    await tester.pumpWidget(
      wrap(
        GeopragTextoInput(
          label: 'Descrição',
          obrigatorio: false,
          onChanged: (_) {},
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('aprova texto preenchido e devolve o valor digitado', (
    tester,
  ) async {
    String? valorRecebido;
    await tester.pumpWidget(
      wrap(
        GeopragTextoInput(
          label: 'Descrição',
          onChanged: (valor) => valorRecebido = valor,
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'Trecho da rua');
    await tester.pump();

    expect(valorRecebido, 'Trecho da rua');
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('limita o tamanho quando tamanhoMaximo é informado', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        GeopragTextoInput(
          label: 'Descrição',
          tamanhoMaximo: 5,
          onChanged: (_) {},
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'abcdefghij');
    await tester.pump();

    expect(find.text('abcde'), findsOneWidget);
  });
}
