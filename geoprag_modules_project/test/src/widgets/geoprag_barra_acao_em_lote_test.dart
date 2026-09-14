import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/widgets/geoprag_barra_acao_em_lote.dart';

void main() {
  group('GeopragBarraAcaoEmLote', () {
    Widget wrap({
      required int quantidade,
      bool processando = false,
      VoidCallback? onAcao,
      VoidCallback? onLimparSelecao,
    }) => MaterialApp(
      home: Scaffold(
        body: GeopragBarraAcaoEmLote(
          opacityKey: const Key('opacity_teste'),
          ignorePointerKey: const Key('ignorePointer_teste'),
          quantidade: quantidade,
          processando: processando,
          onLimparSelecao: onLimparSelecao,
          acoes: [
            GeopragAcaoEmLoteBotao(
              key: const Key('acao_teste'),
              icon: Icons.check,
              label: 'Ação',
              onPressed: processando ? null : onAcao,
            ),
          ],
        ),
      ),
    );

    testWidgets('fica invisível e não interativa sem seleção', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(quantidade: 0));

      final opacity = tester.widget<Opacity>(
        find.byKey(const Key('opacity_teste')),
      );
      final ignorePointer = tester.widget<IgnorePointer>(
        find.byKey(const Key('ignorePointer_teste')),
      );
      expect(opacity.opacity, 0);
      expect(ignorePointer.ignoring, isTrue);
    });

    testWidgets('fica visível e interativa com seleção, mostrando a contagem', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(quantidade: 3));

      final opacity = tester.widget<Opacity>(
        find.byKey(const Key('opacity_teste')),
      );
      final ignorePointer = tester.widget<IgnorePointer>(
        find.byKey(const Key('ignorePointer_teste')),
      );
      expect(opacity.opacity, 1);
      expect(ignorePointer.ignoring, isFalse);
      expect(find.text('3 selecionado(s)'), findsOneWidget);
    });

    testWidgets('aciona onPressed da ação e onLimparSelecao', (tester) async {
      var acaoChamada = false;
      var limparChamado = false;
      await tester.pumpWidget(
        wrap(
          quantidade: 1,
          onAcao: () => acaoChamada = true,
          onLimparSelecao: () => limparChamado = true,
        ),
      );

      await tester.tap(find.byKey(const Key('acao_teste')));
      await tester.tap(find.text('Limpar seleção'));
      await tester.pump();

      expect(acaoChamada, isTrue);
      expect(limparChamado, isTrue);
    });

    testWidgets('desabilita ação e Limpar seleção enquanto processando', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(quantidade: 1, processando: true, onAcao: () {}),
      );

      final botaoAcao = tester.widget<OutlinedButton>(
        find.byKey(const Key('acao_teste')),
      );
      final botaoLimpar = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Limpar seleção'),
      );
      expect(botaoAcao.onPressed, isNull);
      expect(botaoLimpar.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
