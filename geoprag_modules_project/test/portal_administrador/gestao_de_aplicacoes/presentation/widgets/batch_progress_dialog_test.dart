import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/widgets/batch_progress_dialog.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';

/// Guarda o resultado do `showDialog` — não pode ser o valor de retorno de
/// um helper `async`, porque o `Future` só resolve quando o diálogo é
/// fechado (depois de "Concluir"/"Concluir mesmo assim"), e o teste precisa
/// interagir com o diálogo entre abri-lo e fechá-lo.
class _Resultado {
  BatchProgressResultado? valor;
}

Future<_Resultado> _abrir(
  WidgetTester tester, {
  required List<String> ids,
  required Future<void> Function(String id) executarUm,
}) async {
  final resultado = _Resultado();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              resultado.valor = await showDialog<BatchProgressResultado>(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    BatchProgressDialog(ids: ids, executarUm: executarUm),
              );
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
  return resultado;
}

void main() {
  group('BatchProgressDialog', () {
    testWidgets('executa a ação para cada id, na ordem recebida', (
      tester,
    ) async {
      final executados = <String>[];

      await _abrir(
        tester,
        ids: const ['a', 'b', 'c'],
        executarUm: (id) async => executados.add(id),
      );

      expect(executados, ['a', 'b', 'c']);
      expect(find.text('Concluído com sucesso.'), findsOneWidget);
      expect(find.text('Concluir'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsNothing);
    });

    testWidgets('devolve o resultado com sucesso ao concluir', (tester) async {
      final resultado = await _abrir(
        tester,
        ids: const ['a', 'b'],
        executarUm: (id) async {},
      );
      await tester.tap(find.text('Concluir'));
      await tester.pumpAndSettle();

      expect(resultado.valor, isNotNull);
      expect(resultado.valor!.sucesso, ['a', 'b']);
      expect(resultado.valor!.sucessoTotal, isTrue);
    });

    testWidgets(
      'falha parcial mostra o motivo e oferece "Tentar novamente"',
      (tester) async {
        await _abrir(
          tester,
          ids: const ['a', 'b'],
          executarUm: (id) async {
            if (id == 'b') {
              throw const OperacaoNaoPermitidaException('Estado inválido.');
            }
          },
        );

        expect(find.textContaining('1 concluído(s); 1 falharam'), findsOneWidget);
        expect(find.textContaining('Estado inválido.'), findsOneWidget);
        expect(find.text('Tentar novamente'), findsOneWidget);
      },
    );

    testWidgets('Tentar novamente reexecuta só os ids que falharam', (
      tester,
    ) async {
      final tentativas = <String>[];
      var primeiraTentativaDoB = true;

      await _abrir(
        tester,
        ids: const ['a', 'b'],
        executarUm: (id) async {
          tentativas.add(id);
          if (id == 'b' && primeiraTentativaDoB) {
            primeiraTentativaDoB = false;
            throw const OperacaoNaoPermitidaException('Falhou na primeira.');
          }
        },
      );
      expect(tentativas, ['a', 'b']);

      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(tentativas, ['a', 'b', 'b']);
      expect(find.text('Concluído com sucesso.'), findsOneWidget);
    });

    testWidgets('falha total não mostra sucesso nenhum', (tester) async {
      final resultado = await _abrir(
        tester,
        ids: const ['a'],
        executarUm: (id) async =>
            throw const EntidadeNaoEncontradaException('Não encontrado.'),
      );

      expect(find.textContaining('Falha em todos os itens'), findsOneWidget);

      await tester.tap(find.text('Concluir mesmo assim'));
      await tester.pumpAndSettle();

      expect(resultado.valor!.falhaTotal, isTrue);
    });
  });
}
