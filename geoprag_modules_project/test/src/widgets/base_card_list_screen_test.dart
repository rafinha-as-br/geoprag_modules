import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/widgets/base_card_list_screen.dart';

void main() {
  Widget wrap(BaseCardListScreenModel<String> model) => MaterialApp(
    home: Scaffold(body: BaseCardListScreen<String>(model: model)),
  );

  group('BaseCardListScreen', () {
    testWidgets('mostra spinner quando isLoading é true', (tester) async {
      await tester.pumpWidget(
        wrap(
          BaseCardListScreenModel<String>(
            isLoading: true,
            itemBuilder: (context, item) => Text(item),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('mostra a mensagem de erro quando errorMessage é informado', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          BaseCardListScreenModel<String>(
            errorMessage: 'Não foi possível carregar a lista: falha de rede',
            itemBuilder: (context, item) => Text(item),
          ),
        ),
      );

      expect(
        find.text('Não foi possível carregar a lista: falha de rede'),
        findsOneWidget,
      );
    });

    testWidgets('mostra o empty-state quando items está vazio', (tester) async {
      await tester.pumpWidget(
        wrap(
          BaseCardListScreenModel<String>(
            items: const [],
            itemBuilder: (context, item) => Text(item),
            emptyStateMessage: 'Nenhuma solicitação em aberto.',
          ),
        ),
      );

      expect(find.text('Nenhuma solicitação em aberto.'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('trata items null como lista vazia', (tester) async {
      await tester.pumpWidget(
        wrap(
          BaseCardListScreenModel<String>(
            itemBuilder: (context, item) => Text(item),
            emptyStateMessage: 'Nenhum item.',
          ),
        ),
      );

      expect(find.text('Nenhum item.'), findsOneWidget);
    });

    testWidgets('renderiza a lista com itemBuilder e separador padrão', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          BaseCardListScreenModel<String>(
            items: const ['Item A', 'Item B'],
            itemBuilder: (context, item) => Text(item),
          ),
        ),
      );

      expect(find.text('Item A'), findsOneWidget);
      expect(find.text('Item B'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('usa separatorBuilder customizado quando informado', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          BaseCardListScreenModel<String>(
            items: const ['Item A', 'Item B'],
            itemBuilder: (context, item) => Text(item),
            separatorBuilder: (context, index) =>
                const SizedBox(height: 12, key: Key('custom-separator')),
          ),
        ),
      );

      expect(find.byKey(const Key('custom-separator')), findsOneWidget);
      expect(find.byType(Divider), findsNothing);
    });

    test('items do model é imutável', () {
      final model = BaseCardListScreenModel<String>(
        items: ['Item A'],
        itemBuilder: (context, item) => Text(item),
      );

      expect(() => model.items.add('Item B'), throwsUnsupportedError);
    });
  });
}
