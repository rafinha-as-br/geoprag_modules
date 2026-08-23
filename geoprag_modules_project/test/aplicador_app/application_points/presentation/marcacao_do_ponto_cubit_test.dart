import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/application_points/core/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/aplicador_app/application_points/core/ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/aplicador_app/application_points/presentation/marcacao_do_ponto_cubit.dart';
import 'package:geoprag_modules/aplicador_app/application_points/presentation/marcacao_do_ponto_state.dart';
import 'package:mocktail/mocktail.dart';

class MockPontoDeAplicacaoRepository extends Mock
    implements PontoDeAplicacaoRepository {}

void main() {
  late MockPontoDeAplicacaoRepository repository;

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

  setUp(() {
    repository = MockPontoDeAplicacaoRepository();
    registerFallbackValue(capturado);
  });

  blocTest<MarcacaoDoPontoCubit, MarcacaoDoPontoState>(
    'emite [Capturado] com a leitura de GPS quando a captura tem sucesso — '
    'a captura já dispara no construtor',
    setUp: () {
      when(
        () => repository.capturarLocalizacaoAtual(),
      ).thenAnswer((_) async => capturado);
    },
    build: () => MarcacaoDoPontoCubit(repository),
    expect: () => [isA<MarcacaoDoPontoCapturado>()],
  );

  blocTest<MarcacaoDoPontoCubit, MarcacaoDoPontoState>(
    'emite [Erro] com mensagem amigável quando a captura de GPS falha '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(
        () => repository.capturarLocalizacaoAtual(),
      ).thenAnswer((_) async => throw Exception('GPS indisponível'));
    },
    build: () => MarcacaoDoPontoCubit(repository),
    expect: () => [
      isA<MarcacaoDoPontoErro>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );

  blocTest<MarcacaoDoPontoCubit, MarcacaoDoPontoState>(
    'ao salvar com sucesso, emite [Capturado(salvando: true), Salvo]',
    setUp: () {
      when(
        () => repository.capturarLocalizacaoAtual(),
      ).thenAnswer((_) async => capturado);
      when(
        () => repository.marcarPontoInicial(any()),
      ).thenAnswer((_) async {});
    },
    build: () => MarcacaoDoPontoCubit(repository),
    act: (cubit) async {
      // Aguarda a captura de GPS do construtor terminar antes de salvar.
      await Future<void>.delayed(Duration.zero);
      await cubit.salvar();
    },
    expect: () => [
      isA<MarcacaoDoPontoCapturado>(),
      isA<MarcacaoDoPontoCapturado>().having((s) => s.salvando, 'salvando', true),
      isA<MarcacaoDoPontoSalvo>(),
    ],
    verify: (_) {
      verify(() => repository.marcarPontoInicial(capturado)).called(1);
    },
  );

  blocTest<MarcacaoDoPontoCubit, MarcacaoDoPontoState>(
    'ao salvar e o repositório falhar, emite [Capturado(salvando: true), Erro] '
    'com mensagem amigável',
    setUp: () {
      when(
        () => repository.capturarLocalizacaoAtual(),
      ).thenAnswer((_) async => capturado);
      when(
        () => repository.marcarPontoInicial(any()),
      ).thenAnswer((_) async => throw Exception('falha ao enviar para a prefeitura'));
    },
    build: () => MarcacaoDoPontoCubit(repository),
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      await cubit.salvar();
    },
    expect: () => [
      isA<MarcacaoDoPontoCapturado>(),
      isA<MarcacaoDoPontoCapturado>().having((s) => s.salvando, 'salvando', true),
      isA<MarcacaoDoPontoErro>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );

  blocTest<MarcacaoDoPontoCubit, MarcacaoDoPontoState>(
    'salvar() não emite nada se chamado antes da captura de GPS terminar '
    '(guarda contra ponto nulo / estado incompatível)',
    setUp: () {
      // Nunca resolve — simula captura de GPS ainda em andamento.
      when(
        () => repository.capturarLocalizacaoAtual(),
      ).thenAnswer((_) => Completer<PontoDeAplicacao>().future);
    },
    build: () => MarcacaoDoPontoCubit(repository),
    act: (cubit) => cubit.salvar(),
    expect: () => <MarcacaoDoPontoState>[],
    verify: (_) {
      verifyNever(() => repository.marcarPontoInicial(any()));
    },
  );
}
