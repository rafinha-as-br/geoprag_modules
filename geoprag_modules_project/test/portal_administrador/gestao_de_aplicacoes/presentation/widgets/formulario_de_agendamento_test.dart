import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/widgets/formulario_de_agendamento.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';

void main() {
  group('FormularioDeAgendamento', () {
    Widget wrap(ValueChanged<Agendamento?> onChanged) => MaterialApp(
      home: Scaffold(body: FormularioDeAgendamento(onChanged: onChanged)),
    );

    testWidgets('nasce inválido (sem data escolhida) — notifica null', (
      tester,
    ) async {
      Agendamento? recebido;
      var chamadas = 0;
      await tester.pumpWidget(
        wrap((agendamento) {
          chamadas++;
          recebido = agendamento;
        }),
      );

      expect(chamadas, greaterThanOrEqualTo(1));
      expect(recebido, isNull);
    });

    testWidgets('intervalo pré-preenchido com 15 e recorrências com 1', (
      tester,
    ) async {
      await tester.pumpWidget(wrap((_) {}));

      final intervalo = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Intervalo (dias)'),
      );
      final recorrencias = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Quantidade de recorrências'),
      );
      expect(intervalo.controller!.text, '15');
      expect(recorrencias.controller!.text, '1');
    });

    testWidgets('intervalo zero ou negativo não notifica um Agendamento válido', (
      tester,
    ) async {
      Agendamento? ultimo;
      await tester.pumpWidget(wrap((agendamento) => ultimo = agendamento));

      await tester.enterText(
        find.widgetWithText(TextField, 'Intervalo (dias)'),
        '0',
      );
      await tester.pump();

      expect(ultimo, isNull);
    });

    testWidgets('recorrências vazias não notifica um Agendamento válido', (
      tester,
    ) async {
      Agendamento? ultimo;
      await tester.pumpWidget(wrap((agendamento) => ultimo = agendamento));

      await tester.enterText(
        find.widgetWithText(TextField, 'Quantidade de recorrências'),
        '',
      );
      await tester.pump();

      expect(ultimo, isNull);
    });
  });
}
