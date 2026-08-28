import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/core/denuncia.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/core/denuncia_repository.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/core/historico_denuncia.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/presentation/denuncia_detalhe_cubit.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/presentation/visualizacao_individual_denuncia_screen.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:geoprag_modules/src/widgets/geoprag_map_placeholder.dart';
import 'package:mocktail/mocktail.dart';

class MockDenunciaRepository extends Mock implements DenunciaRepository {}

void main() {
  late MockDenunciaRepository repository;

  final denuncia = Denuncia(
    id: '7',
    lat: -26.9,
    lng: -49.06,
    nivelInfestacao: 'Alto',
    descricao: 'Água parada no terreno baldio',
    status: 'Recebida',
    dataHora: DateTime(2026, 6, 20, 14, 30),
    denunciante: 'João Vizinho',
    observacoes: 'Sem observações extras',
  );

  final historico = [
    HistoricoDenuncia(
      titulo: 'Denúncia registrada',
      autor: 'Sistema',
      dataHora: DateTime(2026, 6, 20, 14, 30),
      status: 'Recebida',
    ),
  ];

  setUp(() {
    repository = MockDenunciaRepository();
  });

  Widget wrap() => MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AdminSessionCubit>(create: (_) => AdminSessionCubit()),
        BlocProvider<DenunciaDetalheCubit>(
          create: (_) => DenunciaDetalheCubit(repository, '7'),
        ),
      ],
      child: const VisualizacaoIndividualDenunciaScreen(),
    ),
  );

  testWidgets('mostra spinner enquanto a denúncia carrega', (tester) async {
    when(
      () => repository.buscarPorId('7'),
    ).thenAnswer((_) async => denuncia);
    when(
      () => repository.buscarHistorico('7'),
    ).thenAnswer((_) async => historico);

    await tester.pumpWidget(wrap());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('mostra a mensagem de erro amigável quando o carregamento falha', (
    tester,
  ) async {
    when(() => repository.buscarPorId('7')).thenAnswer(
      (_) async => throw const EntidadeNaoEncontradaException(
        'Denúncia "7" não encontrada.',
      ),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível carregar a denúncia: Denúncia "7" não encontrada.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'mostra denunciante, nível de infestação, descrição e histórico da denúncia carregada',
    (tester) async {
      when(
        () => repository.buscarPorId('7'),
      ).thenAnswer((_) async => denuncia);
      when(
        () => repository.buscarHistorico('7'),
      ).thenAnswer((_) async => historico);

      // Conteúdo em duas colunas não cabe no viewport padrão de teste.
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.text('João Vizinho'), findsOneWidget);
      expect(find.text('Alto'), findsOneWidget);
      expect(find.text('Água parada no terreno baldio'), findsOneWidget);
      expect(find.text('Denúncia registrada'), findsOneWidget);
    },
  );

  testWidgets(
    'usa o GeopragMapPlaceholder consolidado (GEOPRAG-95) para o pin GPS da '
    'denúncia, preservando mensagem e altura originais',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(
        () => repository.buscarPorId('7'),
      ).thenAnswer((_) async => denuncia);
      when(
        () => repository.buscarHistorico('7'),
      ).thenAnswer((_) async => historico);

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.byType(GeopragMapPlaceholder), findsOneWidget);
      final placeholder = tester.widget<GeopragMapPlaceholder>(
        find.byType(GeopragMapPlaceholder),
      );
      expect(
        placeholder.message,
        '[Mapa estático com Pin GPS: -26.9, -49.06]',
      );
      expect(placeholder.height, 150);
    },
  );
}
