import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/distributions/presentation/dashboard_distribuicoes_screen.dart';
import 'package:geoprag_modules/portal_administrador/distributions/presentation/distribuicao_view_model.dart';
import 'package:geoprag_modules/portal_administrador/distributions/presentation/distribuicoes_cubit.dart';
import 'package:geoprag_modules/portal_administrador/distributions/presentation/distribuicoes_state.dart';
import 'package:geoprag_modules/src/widgets/base_card_list_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockDistribuicoesCubit extends MockCubit<DistribuicoesState>
    implements DistribuicoesCubit {}

class MockAdminNavigator extends Mock implements AdminNavigator {}

void main() {
  late MockDistribuicoesCubit cubit;

  Widget wrap(DistribuicoesState state) {
    cubit = MockDistribuicoesCubit();
    whenListen(cubit, Stream.value(state), initialState: state);
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<DistribuicoesCubit>.value(value: cubit),
          BlocProvider<AdminSessionCubit>(create: (_) => AdminSessionCubit()),
        ],
        child: AdminNavigatorScope(
          navigator: MockAdminNavigator(),
          child: const DashboardDistribuicoesScreen(),
        ),
      ),
    );
  }

  group('DashboardDistribuicoesScreen', () {
    // AdminScaffold assume um layout desktop (sidebar fixa de 250px); a
    // viewport padrão de teste (800x600) é estreita demais para o Row do
    // cabeçalho (título + botão) e causa overflow alheio a esta migração.
    void useDesktopViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets('mostra spinner enquanto carrega', (tester) async {
      useDesktopViewport(tester);
      await tester.pumpWidget(wrap(const DistribuicoesLoading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('mostra mensagem de erro amigável', (tester) async {
      useDesktopViewport(tester);
      await tester.pumpWidget(wrap(const DistribuicoesError('falha de rede')));

      expect(
        find.text('Não foi possível carregar as distribuições: falha de rede'),
        findsOneWidget,
      );
    });

    testWidgets('mostra o empty-state quando não há distribuições', (
      tester,
    ) async {
      useDesktopViewport(tester);
      await tester.pumpWidget(wrap(const DistribuicoesLoaded([])));

      expect(find.text('Nenhuma distribuição encontrada.'), findsOneWidget);
    });

    testWidgets('renderiza cada distribuição como ListTile', (tester) async {
      useDesktopViewport(tester);
      await tester.pumpWidget(
        wrap(
          const DistribuicoesLoaded([
            DistribuicaoResumoViewModel(
              id: 'd1',
              produtoNome: 'BTI Líquido',
              quantidade: 2,
              unidade: 'Litros',
              responsavel: 'João Silva',
              bairroResponsavel: 'Belchior',
              dataEntrega: '01/06/2026',
              statusConfirmacao: 'confirmado',
            ),
          ]),
        ),
      );

      expect(find.text('BTI Líquido - 2 Litros'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(BaseCardListScreen<DistribuicaoResumoViewModel>),
          matching: find.byType(ListTile),
        ),
        findsOneWidget,
      );
    });
  });
}
