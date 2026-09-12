import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/tenant/presentation/tenant_cubit.dart';
import 'package:geoprag_modules/aplicador_app/tenant/presentation/tenant_loading_screen.dart';
import 'package:geoprag_modules/aplicador_app/tenant/presentation/tenant_state.dart';
import 'package:geoprag_modules/src/theme/geoprag_colors.dart';

class MockTenantCubit extends MockCubit<TenantState> implements TenantCubit {}

void main() {
  late MockTenantCubit cubit;

  setUp(() {
    cubit = MockTenantCubit();
  });

  Future<void> pumpScreen(WidgetTester tester, TenantState state) async {
    whenListen(cubit, const Stream<TenantState>.empty(), initialState: state);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TenantCubit>.value(
          value: cubit,
          child: const TenantLoadingScreen(),
        ),
      ),
    );
  }

  testWidgets(
    'mostra spinner indeterminado quando o cubit ainda está em TenantInitial',
    (tester) async {
      await pumpScreen(tester, const TenantInitial());

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, isNull);
      expect(find.text('Carregando dados da prefeitura...'), findsOneWidget);
    },
  );

  testWidgets(
    'repassa o progresso do download em TenantDownloading para o slot progress',
    (tester) async {
      await pumpScreen(tester, const TenantDownloading(0.42));

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, 0.42);
      expect(find.text('Baixando mapa da prefeitura... 42%'), findsOneWidget);
    },
  );

  testWidgets('mostra mensagem de erro em vez do spinner em TenantError', (
    tester,
  ) async {
    await pumpScreen(tester, const TenantError('timeout'));

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
}
