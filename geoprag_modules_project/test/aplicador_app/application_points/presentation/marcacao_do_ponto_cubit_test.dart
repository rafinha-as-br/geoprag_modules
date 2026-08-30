import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/application_points/core/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/aplicador_app/application_points/core/ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/aplicador_app/application_points/presentation/marcacao_do_ponto_cubit.dart';
import 'package:geoprag_modules/src/errors/app_error_messages.dart';
import 'package:geoprag_modules/src/widgets/base_form_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockPontoDeAplicacaoRepository extends Mock
    implements PontoDeAplicacaoRepository {}

void main() {
  late MockPontoDeAplicacaoRepository repository;
  late MarcacaoDoPontoCubit cubit;

  final capturado = PontoDeAplicacao(
    id: '1',
    nomePonto: 'Córrego Gasparinho - Ponto 01',
    referencia: 'Rua Pedro Simon, Margem Esquerda',
    latitude: -26.9312,
    longitude: -48.9567,
    precisaoMetros: 4,
    status: 'no_prazo',
    dataUltimaAplicacao: DateTime(2026, 5, 10),
    dataProximaAplicacaoEstimada: DateTime(2026, 5, 25),
  );

  Widget wrap() => MaterialApp(
    home: Scaffold(
      body: BlocProvider<MarcacaoDoPontoCubit>.value(
        value: cubit,
        child: const BaseFormScreen<MarcacaoDoPontoCubit>(),
      ),
    ),
  );

  setUpAll(() {
    registerFallbackValue(capturado);
  });

  setUp(() {
    repository = MockPontoDeAplicacaoRepository();
  });

  group('MarcacaoDoPontoCubit', () {
    testWidgets(
      'mostra a precisão da leitura de GPS assim que a captura termina — a '
      'captura já dispara no construtor',
      (tester) async {
        when(
          () => repository.capturarLocalizacaoAtual(),
        ).thenAnswer((_) async => capturado);
        cubit = MarcacaoDoPontoCubit(repository);

        await tester.pumpWidget(wrap());
        await tester.pump();

        expect(find.textContaining('Alta (4m)'), findsOneWidget);
        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNotNull,
        );
      },
    );

    testWidgets(
      'mostra feedback de erro amigável quando a captura de GPS falha '
      '(nunca expõe a exceção bruta ao usuário)',
      (tester) async {
        when(
          () => repository.capturarLocalizacaoAtual(),
        ).thenAnswer((_) async => throw Exception('GPS indisponível'));
        cubit = MarcacaoDoPontoCubit(repository);

        await tester.pumpWidget(wrap());
        await tester.pump();

        expect(
          find.text(AppErrorMessages.carregamentoGenerico),
          findsOneWidget,
        );
      },
    );

    testWidgets('submete o ponto capturado e emite feedback de sucesso', (
      tester,
    ) async {
      when(
        () => repository.capturarLocalizacaoAtual(),
      ).thenAnswer((_) async => capturado);
      when(
        () => repository.marcarPontoInicial(capturado),
      ).thenAnswer((_) async {});
      cubit = MarcacaoDoPontoCubit(repository);

      await tester.pumpWidget(wrap());
      await tester.pump();

      await tester.tap(find.text('Salvar Ponto Inicial'));
      await tester.pumpAndSettle();

      expect(
        find.text('Localização capturada! Pendente de validação.'),
        findsOneWidget,
      );
      verify(() => repository.marcarPontoInicial(capturado)).called(1);
    });

    testWidgets('mostra spinner e desabilita o botão enquanto salva', (
      tester,
    ) async {
      when(
        () => repository.capturarLocalizacaoAtual(),
      ).thenAnswer((_) async => capturado);
      final envioPendente = Completer<void>();
      when(
        () => repository.marcarPontoInicial(capturado),
      ).thenAnswer((_) => envioPendente.future);
      cubit = MarcacaoDoPontoCubit(repository);

      await tester.pumpWidget(wrap());
      await tester.pump();

      await tester.tap(find.text('Salvar Ponto Inicial'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );

      envioPendente.complete();
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('emite mensagem genérica quando o envio falha '
        '(nunca expõe a exceção bruta ao usuário)', (tester) async {
      when(
        () => repository.capturarLocalizacaoAtual(),
      ).thenAnswer((_) async => capturado);
      when(
        () => repository.marcarPontoInicial(capturado),
      ).thenAnswer((_) async => throw Exception('falha ao enviar'));
      cubit = MarcacaoDoPontoCubit(repository);

      await tester.pumpWidget(wrap());
      await tester.pump();

      await tester.tap(find.text('Salvar Ponto Inicial'));
      await tester.pumpAndSettle();

      expect(find.text(AppErrorMessages.carregamentoGenerico), findsOneWidget);
    });

    testWidgets(
      'tocar o botão sem um ponto capturado não derruba a tela — mostra '
      'feedback de erro em vez de salvar um ponto nulo',
      (tester) async {
        when(
          () => repository.capturarLocalizacaoAtual(),
        ).thenAnswer((_) async => throw Exception('GPS indisponível'));
        cubit = MarcacaoDoPontoCubit(repository);

        await tester.pumpWidget(wrap());
        await tester.pump();

        await tester.tap(find.text('Salvar Ponto Inicial'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        verifyNever(() => repository.marcarPontoInicial(any()));
      },
    );
  });
}
