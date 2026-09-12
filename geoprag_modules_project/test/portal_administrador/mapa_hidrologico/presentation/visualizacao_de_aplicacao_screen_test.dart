import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/core/aplicacao_mapa_repository.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/aplicacao_mapa_cubit.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/visualizacao_de_aplicacao_screen.dart';
import 'package:geoprag_modules/src/entities/aplicacao.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:geoprag_modules/src/widgets/geoprag_map_placeholder.dart';
import 'package:mocktail/mocktail.dart';

class MockAplicacaoMapaRepository extends Mock implements AplicacaoMapaRepository {}

void main() {
  late MockAplicacaoMapaRepository repository;

  final aplicacao = Aplicacao(
    id: '5',
    data: DateTime(2026, 6, 20),
    lat: -26.9,
    lng: -49.06,
    dosagem: 50,
    aplicadorId: '2',
  );

  setUp(() {
    repository = MockAplicacaoMapaRepository();
  });

  Widget wrap() => MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AdminSessionCubit>(create: (_) => AdminSessionCubit()),
        BlocProvider<AplicacaoMapaCubit>(
          create: (_) => AplicacaoMapaCubit(repository, '5'),
        ),
      ],
      child: const VisualizacaoDeAplicacaoScreen(),
    ),
  );

  testWidgets('mostra spinner enquanto a aplicação carrega', (tester) async {
    when(
      () => repository.buscarPorId('5'),
    ).thenAnswer((_) async => aplicacao);

    await tester.pumpWidget(wrap());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('mostra a mensagem de erro amigável quando o carregamento falha', (
    tester,
  ) async {
    when(() => repository.buscarPorId('5')).thenAnswer(
      (_) async => throw const EntidadeNaoEncontradaException(
        'Aplicação "5" não encontrada.',
      ),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível carregar a aplicação: Aplicação "5" não encontrada.'),
      findsOneWidget,
    );
  });

  testWidgets('mostra dosagem, coordenadas e aplicador da aplicação carregada', (
    tester,
  ) async {
    when(
      () => repository.buscarPorId('5'),
    ).thenAnswer((_) async => aplicacao);

    // Conteúdo em duas colunas não cabe no viewport padrão de teste.
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Registrada em 20/06/2026'), findsOneWidget);
    expect(find.text('50.0 ml'), findsOneWidget);
    expect(find.text('-26.9, -49.06'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets(
    'usa o GeopragMapPlaceholder consolidado (GEOPRAG-95) para o ponto da '
    'aplicação, preservando mensagem, ícone e altura originais',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(
        () => repository.buscarPorId('5'),
      ).thenAnswer((_) async => aplicacao);

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.byType(GeopragMapPlaceholder), findsOneWidget);
      final placeholder = tester.widget<GeopragMapPlaceholder>(
        find.byType(GeopragMapPlaceholder),
      );
      expect(placeholder.message, '[Mapa Interativo]\nPonto da aplicação');
      expect(placeholder.icon, Icons.location_on);
      expect(placeholder.height, 260);
    },
  );
}
