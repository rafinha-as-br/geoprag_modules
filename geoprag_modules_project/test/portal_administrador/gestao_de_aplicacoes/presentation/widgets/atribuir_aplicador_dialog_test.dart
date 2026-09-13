import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/widgets/atribuir_aplicador_dialog.dart';

void main() {
  const aplicadores = [
    AplicadorParaAtribuir(
      id: '1',
      nome: 'João Silva',
      bairro: 'Belchior',
      quantidadePontosAtribuidos: 2,
    ),
    AplicadorParaAtribuir(
      id: '2',
      nome: 'Maria Souza',
      bairro: 'Gasparinho',
      quantidadePontosAtribuidos: 7,
    ),
  ];

  Widget wrap() => const MaterialApp(
    home: Material(child: AtribuirAplicadorDialog(aplicadores: aplicadores)),
  );

  group('AtribuirAplicadorDialog', () {
    testWidgets('lista todos os aplicadores recebidos', (tester) async {
      await tester.pumpWidget(wrap());

      expect(find.text('João Silva'), findsOneWidget);
      expect(find.text('Maria Souza'), findsOneWidget);
    });

    testWidgets('busca filtra por nome', (tester) async {
      await tester.pumpWidget(wrap());

      await tester.enterText(find.byType(TextField), 'maria');
      await tester.pump();

      expect(find.text('João Silva'), findsNothing);
      expect(find.text('Maria Souza'), findsOneWidget);
    });

    testWidgets('sem resultado mostra a mensagem de lista vazia', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();

      expect(find.text('Nenhum aplicador encontrado.'), findsOneWidget);
    });

    testWidgets(
      'destaca em âmbar o aplicador com carga alta (>= limite)',
      (tester) async {
        await tester.pumpWidget(wrap());

        final subtitulo = tester.widget<Text>(
          find.textContaining('7 ponto(s) atribuído(s)'),
        );
        expect(subtitulo.style?.fontWeight, FontWeight.bold);
      },
    );

    testWidgets('Atribuir começa desabilitado até selecionar um aplicador', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());

      final atribuir = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Atribuir'),
      );
      expect(atribuir.onPressed, isNull);
    });

    testWidgets('selecionar um aplicador habilita Atribuir', (tester) async {
      await tester.pumpWidget(wrap());

      await tester.tap(find.text('João Silva'));
      await tester.pump();

      final atribuir = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Atribuir'),
      );
      expect(atribuir.onPressed, isNotNull);
    });
  });
}
