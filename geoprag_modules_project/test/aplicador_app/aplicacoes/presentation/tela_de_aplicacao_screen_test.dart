import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/aplicacao_de_campo_view_model.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/tela_de_aplicacao_cubit.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/tela_de_aplicacao_screen.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/tela_de_aplicacao_state.dart';
import 'package:geoprag_modules/aplicador_app/core/aplicador_navigator.dart';
import 'package:mocktail/mocktail.dart';

class MockTelaDeAplicacaoCubit extends MockCubit<TelaDeAplicacaoState>
    implements TelaDeAplicacaoCubit {}

class MockAplicadorNavigator extends Mock implements AplicadorNavigator {}

void main() {
  late MockTelaDeAplicacaoCubit cubit;
  late MockAplicadorNavigator navigator;

  Widget wrap(TelaDeAplicacaoState state) {
    cubit = MockTelaDeAplicacaoCubit();
    navigator = MockAplicadorNavigator();
    whenListen(cubit, Stream.value(state), initialState: state);
    return MaterialApp(
      home: AplicadorNavigatorScope(
        navigator: navigator,
        child: BlocProvider<TelaDeAplicacaoCubit>.value(
          value: cubit,
          child: const TelaDeAplicacaoScreen(),
        ),
      ),
    );
  }

  const ponto = PontoParaAplicacaoViewModel(
    id: 'pa1',
    nome: 'Córrego Gasparinho',
    identificador: '#GAS1',
    enderecoFormatado: 'Rua Pedro Simon, Em frente ao nº 240',
    dosagemFormatada: '120 ml',
    distanciaEntreSubpontosMetros: 50,
    quantidadeDeSubpontos: 2,
    execucoesRegistradas: 0,
  );

  group('TelaDeAplicacaoScreen', () {
    testWidgets('mostra dosagem e o contador de subpontos', (tester) async {
      await tester.pumpWidget(
        wrap(const TelaDeAplicacaoEmAndamento(ponto: ponto)),
      );

      expect(find.text('120 ml'), findsOneWidget);
      expect(find.text('Subponto 0 de 2'), findsOneWidget);
      expect(find.text('Registrar Subponto'), findsOneWidget);
    });

    testWidgets('toca em "Registrar Subponto" e chama o cubit', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const TelaDeAplicacaoEmAndamento(ponto: ponto)),
      );

      await tester.ensureVisible(find.text('Registrar Subponto'));
      await tester.tap(find.text('Registrar Subponto'));
      verify(() => cubit.registrarSubponto()).called(1);
    });

    testWidgets('mostra spinner no botão enquanto registrando', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const TelaDeAplicacaoEmAndamento(ponto: ponto, registrando: true),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
    });

    testWidgets(
      'ao concluir, mostra sucesso e "Voltar para Meus Pontos" navega para /ponto',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            const TelaDeAplicacaoEmAndamento(
              ponto: ponto,
              subpontosRegistrados: 2,
            ),
          ),
        );

        expect(
          find.textContaining('Aplicação registrada com sucesso'),
          findsOneWidget,
        );
        expect(find.text('Registrar Subponto'), findsNothing);

        await tester.ensureVisible(find.text('Voltar para Meus Pontos'));
        await tester.tap(find.text('Voltar para Meus Pontos'));
        verify(() => navigator.toPonto()).called(1);
      },
    );
  });
}
