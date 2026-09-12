import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/core/bairro.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/core/corrego.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/core/corrego_repository.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/bairro_detalhe_cubit.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/detalhe_do_bairro_screen.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:mocktail/mocktail.dart';

class MockCorregoRepository extends Mock implements CorregoRepository {}

void main() {
  late MockCorregoRepository repository;

  const bairro = Bairro(
    id: '1',
    nome: 'Poço Grande',
    status: 'atrasado',
    diasSemAplicacao: 12,
    corregoIds: ['10'],
  );

  const corregos = [
    Corrego(
      id: '10',
      nome: 'Córrego Gasparinho',
      bairro: 'Poço Grande',
      largura: 2.5,
      profundidade: 0.8,
      velocidade: 1.2,
    ),
  ];

  setUp(() {
    repository = MockCorregoRepository();
  });

  Widget wrap() => MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AdminSessionCubit>(create: (_) => AdminSessionCubit()),
        BlocProvider<BairroDetalheCubit>(
          create: (_) => BairroDetalheCubit(repository, '1'),
        ),
      ],
      child: const DetalheDoBairroScreen(),
    ),
  );

  testWidgets('mostra spinner enquanto o bairro carrega', (tester) async {
    when(
      () => repository.buscarBairroPorId('1'),
    ).thenAnswer((_) async => bairro);
    when(
      () => repository.listarCorregosDoBairro('1'),
    ).thenAnswer((_) async => corregos);

    await tester.pumpWidget(wrap());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('mostra a mensagem de erro amigável quando o carregamento falha', (
    tester,
  ) async {
    when(() => repository.buscarBairroPorId('1')).thenAnswer(
      (_) async => throw const EntidadeNaoEncontradaException(
        'Bairro "1" não encontrado.',
      ),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível carregar o bairro: Bairro "1" não encontrado.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'mostra nome, dias sem aplicação, status e os córregos do bairro carregado',
    (tester) async {
      when(
        () => repository.buscarBairroPorId('1'),
      ).thenAnswer((_) async => bairro);
      when(
        () => repository.listarCorregosDoBairro('1'),
      ).thenAnswer((_) async => corregos);

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      // 'Poço Grande' aparece duas vezes: título da tela e bairro do córrego.
      expect(find.text('Poço Grande'), findsNWidgets(2));
      expect(find.text('12 dias sem aplicação'), findsOneWidget);
      expect(find.text('Córrego Gasparinho'), findsOneWidget);
    },
  );

  testWidgets(
    'não estoura o layout (RenderFlex overflow) quando o bairro tem muitos córregos',
    (tester) async {
      final muitosCorregos = List.generate(
        30,
        (i) => Corrego(
          id: '$i',
          nome: 'Córrego $i',
          bairro: 'Poço Grande',
          largura: 2.5,
          profundidade: 0.8,
          velocidade: 1.2,
        ),
      );

      when(
        () => repository.buscarBairroPorId('1'),
      ).thenAnswer((_) async => bairro);
      when(
        () => repository.listarCorregosDoBairro('1'),
      ).thenAnswer((_) async => muitosCorregos);

      // Conteúdo em duas colunas não cabe no viewport padrão de teste.
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Córrego 0'), findsOneWidget);
    },
  );
}
