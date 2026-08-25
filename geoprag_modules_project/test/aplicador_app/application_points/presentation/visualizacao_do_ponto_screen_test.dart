import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/application_points/presentation/ponto_de_aplicacao_cubit.dart';
import 'package:geoprag_modules/aplicador_app/application_points/presentation/ponto_de_aplicacao_state.dart';
import 'package:geoprag_modules/aplicador_app/application_points/presentation/ponto_de_aplicacao_view_model.dart';
import 'package:geoprag_modules/aplicador_app/application_points/presentation/visualizacao_do_ponto_screen.dart';

class MockPontoDeAplicacaoCubit extends MockCubit<PontoDeAplicacaoState>
    implements PontoDeAplicacaoCubit {}

void main() {
  late MockPontoDeAplicacaoCubit cubit;

  Widget wrap(PontoDeAplicacaoState state) {
    cubit = MockPontoDeAplicacaoCubit();
    whenListen(cubit, Stream.value(state), initialState: state);
    return MaterialApp(
      home: BlocProvider<PontoDeAplicacaoCubit>.value(
        value: cubit,
        child: const VisualizacaoDoPontoScreen(),
      ),
    );
  }

  group('VisualizacaoDoPontoScreen', () {
    testWidgets('mostra spinner enquanto carrega', (tester) async {
      await tester.pumpWidget(wrap(const PontoDeAplicacaoLoading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('mostra mensagem de erro amigável', (tester) async {
      await tester.pumpWidget(
        wrap(const PontoDeAplicacaoError('falha de rede')),
      );

      expect(
        find.text('Não foi possível carregar o ponto: falha de rede'),
        findsOneWidget,
      );
    });

    testWidgets('renderiza o ponto de aplicação e o bottom nav', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          PontoDeAplicacaoLoaded(
            PontoDeAplicacaoViewModel(
              nomePonto: 'Ponto Central',
              referencia: 'Próximo à praça',
              estaNoPrazo: true,
              dataUltimaAplicacao: DateTime(2026, 5, 1),
              dataProximaAplicacaoEstimada: DateTime(2026, 6, 1),
            ),
          ),
        ),
      );

      expect(find.text('Ponto Central'), findsOneWidget);
      expect(find.text('Próximo à praça'), findsOneWidget);
      expect(find.text('Ciclo no Prazo'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}
