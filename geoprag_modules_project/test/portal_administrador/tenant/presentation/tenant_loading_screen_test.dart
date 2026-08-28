import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/tenant/presentation/tenant_cubit.dart';
import 'package:geoprag_modules/portal_administrador/tenant/presentation/tenant_loading_screen.dart';
import 'package:geoprag_modules/portal_administrador/tenant/presentation/tenant_state.dart';
import 'package:geoprag_modules/src/theme/geoprag_colors.dart';

class MockAdminTenantCubit extends MockCubit<AdminTenantState>
    implements AdminTenantCubit {}

void main() {
  late MockAdminTenantCubit cubit;

  setUp(() {
    cubit = MockAdminTenantCubit();
  });

  Future<void> pumpScreen(WidgetTester tester, AdminTenantState state) async {
    whenListen(
      cubit,
      const Stream<AdminTenantState>.empty(),
      initialState: state,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AdminTenantCubit>.value(
          value: cubit,
          child: const AdminTenantLoadingScreen(),
        ),
      ),
    );
  }

  testWidgets(
    'mostra spinner indeterminado quando o cubit ainda está em AdminTenantInitial',
    (tester) async {
      await pumpScreen(tester, const AdminTenantInitial());

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, isNull);
      expect(find.text('Carregando dados da prefeitura...'), findsOneWidget);
    },
  );

  testWidgets(
    'o portal administrador não usa o slot progress: spinner continua '
    'indeterminado mesmo em AdminTenantDownloading',
    (tester) async {
      await pumpScreen(tester, const AdminTenantDownloading(0.42));

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, isNull);
      expect(find.text('Carregando dados da prefeitura...'), findsOneWidget);
    },
  );

  testWidgets('mostra mensagem de erro em vez do spinner em AdminTenantError', (
    tester,
  ) async {
    await pumpScreen(tester, const AdminTenantError('timeout'));

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
