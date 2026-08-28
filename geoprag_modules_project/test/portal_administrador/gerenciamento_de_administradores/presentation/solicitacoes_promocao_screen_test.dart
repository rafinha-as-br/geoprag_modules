import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/solicitacao_promocao_view_model.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/solicitacoes_promocao_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/solicitacoes_promocao_screen.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/solicitacoes_promocao_state.dart';
import 'package:mocktail/mocktail.dart';

class MockSolicitacoesPromocaoCubit
    extends MockCubit<SolicitacoesPromocaoState>
    implements SolicitacoesPromocaoCubit {}

class MockAdminNavigator extends Mock implements AdminNavigator {}

void main() {
  late MockSolicitacoesPromocaoCubit cubit;

  Widget wrap(SolicitacoesPromocaoState state) {
    cubit = MockSolicitacoesPromocaoCubit();
    whenListen(cubit, Stream.value(state), initialState: state);
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SolicitacoesPromocaoCubit>.value(value: cubit),
          BlocProvider<AdminSessionCubit>(create: (_) => AdminSessionCubit()),
        ],
        child: AdminNavigatorScope(
          navigator: MockAdminNavigator(),
          child: const SolicitacoesPromocaoScreen(),
        ),
      ),
    );
  }

  group('SolicitacoesPromocaoScreen', () {
    // AdminScaffold assume um layout desktop (sidebar fixa de 250px); a
    // viewport padrão de teste (800x600) é estreita demais para o Row de
    // contadores de voto do card e causa overflow alheio a esta migração.
    void useDesktopViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets('mostra spinner enquanto carrega', (tester) async {
      useDesktopViewport(tester);
      await tester.pumpWidget(wrap(const SolicitacoesPromocaoLoading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('mostra mensagem de erro amigável', (tester) async {
      useDesktopViewport(tester);
      await tester.pumpWidget(
        wrap(const SolicitacoesPromocaoError('falha de rede')),
      );

      expect(
        find.text('Não foi possível carregar as solicitações: falha de rede'),
        findsOneWidget,
      );
    });

    testWidgets('mostra o empty-state quando não há solicitações', (
      tester,
    ) async {
      useDesktopViewport(tester);
      await tester.pumpWidget(wrap(const SolicitacoesPromocaoLoaded([])));

      expect(
        find.text('Nenhuma solicitação de promoção em aberto.'),
        findsOneWidget,
      );
    });

    testWidgets('renderiza cada solicitação como card', (tester) async {
      useDesktopViewport(tester);
      await tester.pumpWidget(
        wrap(
          const SolicitacoesPromocaoLoaded([
            SolicitacaoPromocaoViewModel(
              id: 's1',
              subAdministradorEmail: 'sub@geoprag.com',
              subAdministradorNome: 'Maria Souza',
              solicitanteEmail: 'req@geoprag.com',
              solicitanteNome: 'João Silva',
              votosFavoraveis: 2,
              votosContrarios: 0,
              limiar: 3,
              jaVotei: false,
              souOSolicitante: false,
            ),
          ]),
        ),
      );

      expect(
        find.text('Promoção de Maria Souza a Administrador'),
        findsOneWidget,
      );
      expect(find.text('Solicitado por João Silva'), findsOneWidget);
    });
  });
}
