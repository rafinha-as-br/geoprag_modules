import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/aplicacao_de_campo_view_model.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/geolocalizacao_cubit.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/geolocalizacao_screen.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/geolocalizacao_state.dart';
import 'package:geoprag_modules/aplicador_app/core/aplicador_navigator.dart';
import 'package:mocktail/mocktail.dart';

class MockGeolocalizacaoCubit extends MockCubit<GeolocalizacaoState>
    implements GeolocalizacaoCubit {}

class MockAplicadorNavigator extends Mock implements AplicadorNavigator {}

void main() {
  late MockGeolocalizacaoCubit cubit;
  late MockAplicadorNavigator navigator;

  Widget wrap(GeolocalizacaoState state) {
    cubit = MockGeolocalizacaoCubit();
    navigator = MockAplicadorNavigator();
    when(() => cubit.verificarChegada()).thenAnswer((_) async {});
    whenListen(cubit, Stream.value(state), initialState: state);
    return MaterialApp(
      home: AplicadorNavigatorScope(
        navigator: navigator,
        child: BlocProvider<GeolocalizacaoCubit>.value(
          value: cubit,
          child: const GeolocalizacaoScreen(),
        ),
      ),
    );
  }

  const primeiraAplicacao = PontoParaAplicacaoViewModel(
    id: 'pa1',
    nome: 'Córrego Gasparinho',
    identificador: '#GAS1',
    enderecoFormatado: 'Rua Pedro Simon, Em frente ao nº 240',
    dosagemFormatada: '120 ml',
    distanciaEntreSubpontosMetros: 75,
    quantidadeDeSubpontos: 8,
    execucoesRegistradas: 0,
  );

  const revisita = PontoParaAplicacaoViewModel(
    id: 'pa1',
    nome: 'Córrego Gasparinho',
    identificador: '#GAS1',
    enderecoFormatado: 'Rua Pedro Simon, Em frente ao nº 240',
    dosagemFormatada: '120 ml',
    distanciaEntreSubpontosMetros: 75,
    quantidadeDeSubpontos: 8,
    execucoesRegistradas: 2,
  );

  ElevatedButton botaoIniciar(WidgetTester tester) =>
      tester.widget(find.widgetWithText(ElevatedButton, 'Iniciar Aplicação'));

  group('GeolocalizacaoScreen', () {
    testWidgets('identifica a primeira aplicação', (tester) async {
      await tester.pumpWidget(
        wrap(const GeolocalizacaoLoaded(ponto: primeiraAplicacao)),
      );

      expect(find.text('Primeira aplicação neste ponto'), findsOneWidget);
    });

    testWidgets('identifica a revisita e mostra o trajeto anterior', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const GeolocalizacaoLoaded(ponto: revisita)),
      );

      expect(
        find.text('Revisita — 2 aplicação(ões) anterior(es)'),
        findsOneWidget,
      );
      expect(find.text('Trajeto da visita anterior'), findsOneWidget);
    });

    testWidgets('enquanto lê o GPS, mostra o progresso e bloqueia o botão', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const GeolocalizacaoLoaded(ponto: revisita)),
      );

      expect(find.text('Verificando sua localização…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(botaoIniciar(tester).onPressed, isNull);
    });

    testWidgets('fora do raio mostra a distância medida e bloqueia o botão', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const GeolocalizacaoLoaded(
            ponto: revisita,
            verificacao: ChegadaForaDoRaio(250.4),
          ),
        ),
      );

      expect(find.text('Desloque-se até o ponto'), findsOneWidget);
      expect(find.textContaining('aprox. 250 m'), findsOneWidget);
      expect(find.textContaining('até 100 m'), findsOneWidget);
      expect(botaoIniciar(tester).onPressed, isNull);
    });

    testWidgets(
      'sem posição mostra a orientação, não deixa iniciar e permite tentar de novo',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            const GeolocalizacaoLoaded(
              ponto: revisita,
              verificacao: ChegadaSemPosicao('O GPS está desligado.'),
            ),
          ),
        );

        expect(find.text('O GPS está desligado.'), findsOneWidget);
        expect(botaoIniciar(tester).onPressed, isNull);

        await tester.ensureVisible(
          find.byKey(const Key('geolocalizacaoScreen_tentarDeNovo')),
        );
        await tester.tap(
          find.byKey(const Key('geolocalizacaoScreen_tentarDeNovo')),
        );
        verify(() => cubit.verificarChegada()).called(1);
      },
    );

    testWidgets(
      'dentro do raio libera "Iniciar Aplicação" e navega com o pontoId',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            const GeolocalizacaoLoaded(
              ponto: revisita,
              verificacao: ChegadaConfirmada(distanciaMetros: 42),
            ),
          ),
        );

        expect(find.text('Você chegou ao local!'), findsOneWidget);
        expect(
          find.byKey(const Key('geolocalizacaoScreen_tentarDeNovo')),
          findsNothing,
        );

        await tester.ensureVisible(find.text('Iniciar Aplicação'));
        await tester.tap(find.text('Iniciar Aplicação'));
        verify(() => navigator.toAplicacaoRegistrar('pa1')).called(1);
      },
    );

    testWidgets(
      'na primeira aplicação a chegada não é validada e libera o início',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            const GeolocalizacaoLoaded(
              ponto: primeiraAplicacao,
              verificacao: ChegadaConfirmada(),
            ),
          ),
        );

        expect(find.text('Pronto para iniciar'), findsOneWidget);
        expect(find.textContaining('referência do ponto'), findsOneWidget);
        expect(botaoIniciar(tester).onPressed, isNotNull);
      },
    );
  });
}
