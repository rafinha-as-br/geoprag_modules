import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/detalhe_do_ponto_cubit.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/detalhe_do_ponto_screen.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/detalhe_do_ponto_state.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/detalhe_do_ponto_view_model.dart';
import 'package:geoprag_modules/aplicador_app/core/aplicador_navigator.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:mocktail/mocktail.dart';

class MockDetalheDoPontoDesignadoCubit
    extends MockCubit<DetalheDoPontoDesignadoState>
    implements DetalheDoPontoDesignadoCubit {}

class MockAplicadorNavigator extends Mock implements AplicadorNavigator {}

void main() {
  late MockDetalheDoPontoDesignadoCubit cubit;
  late MockAplicadorNavigator navigator;

  Widget wrap(DetalheDoPontoDesignadoState state) {
    cubit = MockDetalheDoPontoDesignadoCubit();
    navigator = MockAplicadorNavigator();
    whenListen(cubit, Stream.value(state), initialState: state);
    return MaterialApp(
      home: AplicadorNavigatorScope(
        navigator: navigator,
        child: BlocProvider<DetalheDoPontoDesignadoCubit>.value(
          value: cubit,
          child: const DetalheDoPontoDesignadoScreen(),
        ),
      ),
    );
  }

  DetalheDoPontoDesignadoViewModel viewModel({
    EstadoPontoDeAplicacao estado = EstadoPontoDeAplicacao.ativa,
    List<Subponto> execucoes = const [],
  }) {
    return DetalheDoPontoDesignadoViewModel(
      id: 'pa1',
      identificador: '#GAS1',
      nome: 'Córrego Gasparinho',
      bairro: 'Gasparinho',
      endereco: 'Rua Pedro Simon',
      numeroReferencia: 'Em frente ao nº 240',
      descricaoDoTrecho: 'Trecho de 400 m.',
      estado: estado,
      dosagemFormatada: '120 ml',
      distanciaEntreSubpontosMetros: 50,
      quantidadeDeSubpontos: 8,
      execucoes: execucoes,
    );
  }

  group('DetalheDoPontoDesignadoScreen', () {
    testWidgets('mostra spinner enquanto carrega', (tester) async {
      await tester.pumpWidget(wrap(const DetalheDoPontoDesignadoLoading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('mostra mensagem de erro amigável', (tester) async {
      await tester.pumpWidget(
        wrap(const DetalheDoPontoDesignadoError('falha de rede')),
      );

      expect(
        find.textContaining('Não foi possível carregar o ponto'),
        findsOneWidget,
      );
    });

    testWidgets('mostra dosagem, distância cadastrada e "Primeira aplicação"', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(DetalheDoPontoDesignadoLoaded(viewModel())),
      );

      expect(find.text('120 ml'), findsOneWidget);
      expect(find.textContaining('Distância entre subpontos: 50 m'), findsOneWidget);
      expect(find.text('Primeira aplicação'), findsOneWidget);
    });

    testWidgets('mostra "Revisita" quando já há histórico de execuções', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          DetalheDoPontoDesignadoLoaded(
            viewModel(
              execucoes: [
                Subponto(
                  latitude: 0,
                  longitude: 0,
                  realizadoEm: DateTime(2026, 8, 1),
                  registradoEm: DateTime(2026, 8, 1),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Revisita'), findsOneWidget);
    });

    testWidgets(
      'botão "Iniciar Aplicação" habilitado só quando o ponto está ativo',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            DetalheDoPontoDesignadoLoaded(
              viewModel(estado: EstadoPontoDeAplicacao.inativa),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(
          find.byKey(const Key('detalheDoPontoDesignadoScreen_iniciarAplicacao')),
        );
        expect(button.onPressed, isNull);
      },
    );

    testWidgets('toca em "Iniciar Aplicação" e navega para a tela informativa', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(DetalheDoPontoDesignadoLoaded(viewModel())),
      );

      final botao = find.byKey(
        const Key('detalheDoPontoDesignadoScreen_iniciarAplicacao'),
      );
      await tester.ensureVisible(botao);
      await tester.tap(botao);
      verify(() => navigator.toAplicacaoInfo('pa1')).called(1);
    });
  });
}
