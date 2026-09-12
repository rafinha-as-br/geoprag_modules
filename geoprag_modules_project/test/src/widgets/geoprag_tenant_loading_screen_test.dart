import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/theme/geoprag_colors.dart';
import 'package:geoprag_modules/src/widgets/geoprag_tenant_loading_screen.dart';

void main() {
  group('GeopragTenantLoadingScreen', () {
    testWidgets(
      'mostra spinner indeterminado e texto padrão quando progress é nulo',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: GeopragTenantLoadingScreen()),
        );

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.value, isNull);
        expect(indicator.color, GeopragColors.green900);
        expect(find.text('Carregando dados da prefeitura...'), findsOneWidget);
      },
    );

    testWidgets(
      'mostra spinner determinístico e porcentagem quando progress é informado',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: GeopragTenantLoadingScreen(progress: 0.42),
          ),
        );

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.value, 0.42);
        expect(
          find.text('Baixando mapa da prefeitura... 42%'),
          findsOneWidget,
        );
      },
    );

    testWidgets('mostra mensagem de erro em vez do spinner quando isError', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GeopragTenantLoadingScreen(
            isError: true,
            errorMessage: 'timeout',
          ),
        ),
      );

      expect(
        find.text('Não foi possível carregar a prefeitura: timeout'),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);

      final text = tester.widget<Text>(
        find.text('Não foi possível carregar a prefeitura: timeout'),
      );
      expect(text.style?.color, GeopragColors.statusAtrasado);
    });
  });
}
