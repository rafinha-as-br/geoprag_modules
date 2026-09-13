import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/widgets/desativar_dialog.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';

class _Resultado {
  bool? valor;
}

Future<_Resultado> _abrir(
  WidgetTester tester, {
  required Agendamento? agendamento,
}) async {
  final resultado = _Resultado();
  await tester.pumpWidget(
    MaterialApp(
      home: Material(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              resultado.valor = await showDesativarDialog(
                context,
                agendamento: agendamento,
              );
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('abrir'));
  // `pump()` em vez de `pumpAndSettle()`: evita o gatilho de compilação de
  // shader (ink_sparkle.frag) que quebra neste ambiente de teste local —
  // ver GEOPRAG-101/GEOPRAG-110, mesmo problema pré-existente documentado.
  await tester.pump();
  return resultado;
}

void main() {
  group('showDesativarDialog', () {
    testWidgets('sem agendamento não mostra o bloco de datas canceladas', (
      tester,
    ) async {
      await _abrir(tester, agendamento: null);

      expect(find.textContaining('será(ão) cancelada(s)'), findsNothing);
    });

    testWidgets(
      'com agendamento vigente mostra quantas datas pendentes serão canceladas',
      (tester) async {
        final agendamento = Agendamento.gerar(
          dataInicio: DateTime(2026, 9, 10),
          intervaloDias: 15,
          quantidadeRecorrencias: 3,
        );
        final comUmaConcluida = Agendamento(
          dataInicio: agendamento.dataInicio,
          intervaloDias: agendamento.intervaloDias,
          quantidadeRecorrencias: agendamento.quantidadeRecorrencias,
          datas: [
            agendamento.datas[0].copyWith(status: StatusDataAgendada.concluida),
            agendamento.datas[1],
            agendamento.datas[2],
          ],
        );

        await _abrir(tester, agendamento: comUmaConcluida);

        expect(find.textContaining('2 data(s) futura(s)'), findsOneWidget);
        expect(
          find.text('O aplicador responsável será avisado.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('lista os quatro itens explicativos, na ordem', (
      tester,
    ) async {
      await _abrir(tester, agendamento: null);

      expect(find.textContaining('Não é uma exclusão'), findsOneWidget);
      expect(find.textContaining('histórico de execuções é preservado'), findsOneWidget);
      expect(find.textContaining('some das listas e do mapa'), findsOneWidget);
      expect(find.textContaining('Reativável a qualquer momento'), findsOneWidget);
    });
  });
}
