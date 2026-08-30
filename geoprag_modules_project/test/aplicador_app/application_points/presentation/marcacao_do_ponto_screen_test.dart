import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/application_points/core/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/aplicador_app/application_points/core/ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/aplicador_app/application_points/presentation/marcacao_do_ponto_cubit.dart';
import 'package:geoprag_modules/aplicador_app/application_points/presentation/marcacao_do_ponto_screen.dart';
import 'package:geoprag_modules/aplicador_app/core/aplicador_navigator.dart';
import 'package:geoprag_modules/src/widgets/geoprag_map_placeholder.dart';
import 'package:mocktail/mocktail.dart';

class MockPontoDeAplicacaoRepository extends Mock
    implements PontoDeAplicacaoRepository {}

class MockAplicadorNavigator extends Mock implements AplicadorNavigator {}

void main() {
  testWidgets(
    'usa o GeopragMapPlaceholder consolidado (GEOPRAG-95) no lugar da '
    'Image.network hardcoded, mantendo o círculo de precisão sobreposto',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = MockPontoDeAplicacaoRepository();
      final ponto = PontoDeAplicacao(
        id: 'p1',
        nomePonto: 'Ponto 1',
        referencia: 'Ao lado do mercado',
        latitude: -26.9328,
        longitude: -48.9554,
        precisaoMetros: 5,
        status: 'no_prazo',
        dataUltimaAplicacao: DateTime(2026, 4, 1),
        dataProximaAplicacaoEstimada: DateTime(2026, 6, 1),
      );
      when(
        () => repository.capturarLocalizacaoAtual(),
      ).thenAnswer((_) async => ponto);

      await tester.pumpWidget(
        MaterialApp(
          home: AplicadorNavigatorScope(
            navigator: MockAplicadorNavigator(),
            child: BlocProvider<MarcacaoDoPontoCubit>(
              create: (_) => MarcacaoDoPontoCubit(repository),
              child: const MarcacaoDoPontoScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(GeopragMapPlaceholder), findsOneWidget);
      final placeholder = tester.widget<GeopragMapPlaceholder>(
        find.byType(GeopragMapPlaceholder),
      );
      expect(placeholder.message, '[Mapa Interativo]');
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    },
  );

  testWidgets('volta para a tela anterior ao salvar com sucesso', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = MockPontoDeAplicacaoRepository();
    final navigator = MockAplicadorNavigator();
    final ponto = PontoDeAplicacao(
      id: 'p1',
      nomePonto: 'Ponto 1',
      referencia: 'Ao lado do mercado',
      latitude: -26.9328,
      longitude: -48.9554,
      precisaoMetros: 5,
      status: 'no_prazo',
      dataUltimaAplicacao: DateTime(2026, 4, 1),
      dataProximaAplicacaoEstimada: DateTime(2026, 6, 1),
    );
    when(
      () => repository.capturarLocalizacaoAtual(),
    ).thenAnswer((_) async => ponto);
    when(() => repository.marcarPontoInicial(ponto)).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: AplicadorNavigatorScope(
          navigator: navigator,
          child: BlocProvider<MarcacaoDoPontoCubit>(
            create: (_) => MarcacaoDoPontoCubit(repository),
            child: const MarcacaoDoPontoScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Salvar Ponto Inicial'));
    await tester.tap(find.text('Salvar Ponto Inicial'));
    await tester.pumpAndSettle();

    verify(() => navigator.back()).called(1);
  });
}
