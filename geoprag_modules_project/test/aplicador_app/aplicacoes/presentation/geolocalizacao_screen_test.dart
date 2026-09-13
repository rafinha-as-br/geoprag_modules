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

  group('GeolocalizacaoScreen', () {
    testWidgets('mostra a distância cadastrada do ponto, não mais 150m fixo', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const GeolocalizacaoLoaded(ponto: primeiraAplicacao)),
      );

      expect(find.textContaining('aprox. 75m de distância'), findsOneWidget);
      expect(find.textContaining('150m'), findsNothing);
    });

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

    testWidgets('toca em "Simular chegada" e chama confirmarChegada', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const GeolocalizacaoLoaded(ponto: primeiraAplicacao)),
      );

      await tester.ensureVisible(find.text('Simular chegada ao ponto (Mock)'));
      await tester.tap(find.text('Simular chegada ao ponto (Mock)'));
      verify(() => cubit.confirmarChegada()).called(1);
    });

    testWidgets(
      'toca em "Iniciar Aplicação" (dentro do raio) e navega com o pontoId',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            const GeolocalizacaoLoaded(
              ponto: primeiraAplicacao,
              dentroDoRaio: true,
            ),
          ),
        );

        await tester.ensureVisible(find.text('Iniciar Aplicação'));
        await tester.tap(find.text('Iniciar Aplicação'));
        verify(() => navigator.toAplicacaoRegistrar('pa1')).called(1);
      },
    );
  });
}
