import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/meus_pontos_cubit.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/meus_pontos_screen.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/meus_pontos_state.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/meus_pontos_view_model.dart';
import 'package:geoprag_modules/aplicador_app/core/aplicador_navigator.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:mocktail/mocktail.dart';

class MockMeusPontosCubit extends MockCubit<MeusPontosState>
    implements MeusPontosCubit {}

class MockAplicadorNavigator extends Mock implements AplicadorNavigator {}

void main() {
  late MockMeusPontosCubit cubit;
  late MockAplicadorNavigator navigator;

  Widget wrap(MeusPontosState state) {
    cubit = MockMeusPontosCubit();
    navigator = MockAplicadorNavigator();
    whenListen(cubit, Stream.value(state), initialState: state);
    return MaterialApp(
      home: AplicadorNavigatorScope(
        navigator: navigator,
        child: BlocProvider<MeusPontosCubit>.value(
          value: cubit,
          child: const MeusPontosScreen(),
        ),
      ),
    );
  }

  final resumo = PontoDoAplicadorResumoViewModel(
    id: 'pa1',
    identificador: '#GAS1',
    nome: 'Córrego Gasparinho',
    bairro: 'Gasparinho',
    estado: EstadoPontoDeAplicacao.ativa,
    dosagemFormatada: '120 ml',
    execucoesRegistradas: 2,
    quantidadeDeSubpontos: 8,
    ativoSemRegistro: false,
  );

  group('MeusPontosScreen', () {
    testWidgets('mostra spinner enquanto carrega', (tester) async {
      await tester.pumpWidget(wrap(const MeusPontosLoading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('mostra mensagem de erro amigável', (tester) async {
      await tester.pumpWidget(wrap(const MeusPontosError('falha de rede')));

      expect(
        find.textContaining('Não foi possível carregar seus pontos'),
        findsOneWidget,
      );
    });

    testWidgets('mostra mensagem de lista vazia', (tester) async {
      await tester.pumpWidget(wrap(const MeusPontosLoaded([])));

      expect(
        find.text('Nenhum ponto de aplicação atribuído a você ainda.'),
        findsOneWidget,
      );
    });

    testWidgets('renderiza o card do ponto, o banner offline e o bottom nav', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(MeusPontosLoaded([resumo])));

      expect(find.text('Córrego Gasparinho'), findsOneWidget);
      expect(find.text('#GAS1 · Gasparinho'), findsOneWidget);
      expect(find.textContaining('Sincronização automática'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('destaca alerta quando o ponto está ativo sem registro', (
      tester,
    ) async {
      final alerta = PontoDoAplicadorResumoViewModel(
        id: 'pa2',
        identificador: '#BEL1',
        nome: 'Córrego Belchior',
        bairro: 'Belchior',
        estado: EstadoPontoDeAplicacao.ativa,
        dosagemFormatada: '90 ml',
        execucoesRegistradas: 0,
        quantidadeDeSubpontos: 5,
        ativoSemRegistro: true,
      );

      await tester.pumpWidget(wrap(MeusPontosLoaded([alerta])));

      expect(
        find.text('Ativo e sem nenhuma aplicação registrada'),
        findsOneWidget,
      );
    });

    testWidgets('toca no card e navega para o detalhe do ponto', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(MeusPontosLoaded([resumo])));

      await tester.tap(find.text('Córrego Gasparinho'));
      verify(() => navigator.toPontoDetalhe('pa1')).called(1);
    });
  });
}
