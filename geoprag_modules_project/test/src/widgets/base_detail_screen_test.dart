import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/widgets/base_detail_screen.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('BaseDetailScreen', () {
    testWidgets('mostra spinner quando isLoading é true, sem header', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          BaseDetailScreen(
            variant: BaseDetailScreenVariant.duasColunas,
            title: 'Título',
            isLoading: true,
            contentBuilder: (context) => const Text('conteúdo'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Título'), findsNothing);
      expect(find.text('conteúdo'), findsNothing);
    });

    testWidgets('mostra a mensagem de erro quando errorMessage é informado', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          BaseDetailScreen(
            variant: BaseDetailScreenVariant.duasColunas,
            title: 'Título',
            isLoading: false,
            errorMessage: 'Não foi possível carregar: falha de rede',
            contentBuilder: (context) => const Text('conteúdo'),
          ),
        ),
      );

      expect(
        find.text('Não foi possível carregar: falha de rede'),
        findsOneWidget,
      );
      expect(find.text('conteúdo'), findsNothing);
    });

    testWidgets(
      'variante duasColunas mostra título (fontSize 28) e conteúdo sem Card externo',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            BaseDetailScreen(
              variant: BaseDetailScreenVariant.duasColunas,
              title: 'João Silva',
              isLoading: false,
              contentBuilder: (context) => const Text('perfil'),
            ),
          ),
        );

        final titleText = tester.widget<Text>(find.text('João Silva'));
        expect(titleText.style?.fontSize, 28);
        expect(find.text('perfil'), findsOneWidget);
        expect(find.byType(Card), findsNothing);
      },
    );

    testWidgets(
      'variante cartaoCentralizado envolve em Container(600) + Card(elevation:4, radius:16) com título fontSize 24',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            BaseDetailScreen(
              variant: BaseDetailScreenVariant.cartaoCentralizado,
              title: 'Produto X - Lote 1',
              isLoading: false,
              contentBuilder: (context) => const Text('detalhes do produto'),
            ),
          ),
        );

        final titleText = tester.widget<Text>(find.text('Produto X - Lote 1'));
        expect(titleText.style?.fontSize, 24);

        final card = tester.widget<Card>(find.byType(Card));
        expect(card.elevation, 4);
        expect(
          (card.shape as RoundedRectangleBorder).borderRadius,
          BorderRadius.circular(16),
        );

        final container = tester.widget<Container>(find.byType(Container));
        expect(container.constraints?.maxWidth, 600);
      },
    );

    testWidgets('mostra actions à direita do título quando informadas', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          BaseDetailScreen(
            variant: BaseDetailScreenVariant.duasColunas,
            title: 'Título',
            isLoading: false,
            actions: [
              ElevatedButton(onPressed: () {}, child: const Text('Editar')),
            ],
            contentBuilder: (context) => const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.text('Editar'), findsOneWidget);
    });

    testWidgets('não renderiza Row de actions quando a lista está vazia', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          BaseDetailScreen(
            variant: BaseDetailScreenVariant.duasColunas,
            title: 'Título',
            isLoading: false,
            contentBuilder: (context) => const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}
