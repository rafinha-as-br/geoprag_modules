import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/core/corrego.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/core/corrego_repository.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/corrego_detalhe_cubit.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/visualizacao_de_corrego_screen.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:mocktail/mocktail.dart';

class MockCorregoRepository extends Mock implements CorregoRepository {}

void main() {
  late MockCorregoRepository repository;

  const corrego = Corrego(
    id: '10',
    nome: 'Córrego Gasparinho',
    bairro: 'Poço Grande',
    largura: 2.5,
    profundidade: 0.8,
    velocidade: 1.2,
  );

  setUp(() {
    repository = MockCorregoRepository();
  });

  Widget wrap() => MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AdminSessionCubit>(create: (_) => AdminSessionCubit()),
        BlocProvider<CorregoDetalheCubit>(
          create: (_) => CorregoDetalheCubit(repository, '10'),
        ),
      ],
      child: const VisualizacaoDeCorregoScreen(),
    ),
  );

  testWidgets('mostra spinner enquanto o córrego carrega', (tester) async {
    when(
      () => repository.buscarPorId('10'),
    ).thenAnswer((_) async => corrego);

    await tester.pumpWidget(wrap());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('mostra a mensagem de erro amigável quando o carregamento falha', (
    tester,
  ) async {
    when(() => repository.buscarPorId('10')).thenAnswer(
      (_) async => throw const EntidadeNaoEncontradaException(
        'Córrego "10" não encontrado.',
      ),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível carregar o córrego: Córrego "10" não encontrado.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'mostra nome, bairro e as medições do córrego carregado',
    (tester) async {
      when(
        () => repository.buscarPorId('10'),
      ).thenAnswer((_) async => corrego);

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.text('Córrego Gasparinho'), findsOneWidget);
      expect(find.text('Bairro: Poço Grande'), findsOneWidget);
      expect(find.text('2.5 m'), findsOneWidget);
      expect(find.text('0.8 m'), findsOneWidget);
      expect(find.text('1.2 m/s'), findsOneWidget);
    },
  );
}
