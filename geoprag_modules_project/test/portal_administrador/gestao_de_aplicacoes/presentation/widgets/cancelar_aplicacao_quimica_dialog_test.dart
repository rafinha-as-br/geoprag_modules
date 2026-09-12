import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/widgets/cancelar_aplicacao_quimica_dialog.dart';

class _Resultado {
  bool? valor;
}

Future<_Resultado> _abrir(WidgetTester tester) async {
  final resultado = _Resultado();
  await tester.pumpWidget(
    MaterialApp(
      home: Material(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              resultado.valor = await showCancelarAplicacaoQuimicaDialog(
                context,
              );
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('abrir'));
  // `pump()`, não `pumpAndSettle()`: evita o gatilho de compilação de
  // shader (ink_sparkle.frag) que quebra neste ambiente de teste local —
  // mesmo problema pré-existente documentado nas GEOPRAG-101/110.
  await tester.pump();
  return resultado;
}

void main() {
  group('showCancelarAplicacaoQuimicaDialog', () {
    testWidgets(
      'mostra o bloco verde "Nada é apagado" antes do âmbar "O que muda"',
      (tester) async {
        await _abrir(tester);

        final nadaEApagado = tester.getTopLeft(find.text('Nada é apagado'));
        final oQueMuda = tester.getTopLeft(find.text('O que muda'));
        expect(
          nadaEApagado.dy,
          lessThan(oQueMuda.dy),
          reason: '"Nada é apagado" deve vir antes de "O que muda"',
        );
      },
    );

    testWidgets(
      'botão secundário nunca se chama "Cancelar" (ambíguo com a ação)',
      (tester) async {
        await _abrir(tester);

        expect(find.widgetWithText(TextButton, 'Cancelar'), findsNothing);
        expect(find.text('Voltar'), findsOneWidget);
      },
    );

    testWidgets('menciona explicitamente que o histórico é preservado', (
      tester,
    ) async {
      await _abrir(tester);

      expect(
        find.textContaining('histórico de aplicações já realizadas'),
        findsOneWidget,
      );
    });
  });
}
