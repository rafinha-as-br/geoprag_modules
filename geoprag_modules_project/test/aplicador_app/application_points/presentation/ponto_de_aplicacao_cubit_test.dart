import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/application_points/core/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/aplicador_app/application_points/core/ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/aplicador_app/application_points/presentation/ponto_de_aplicacao_cubit.dart';
import 'package:geoprag_modules/aplicador_app/application_points/presentation/ponto_de_aplicacao_state.dart';
import 'package:mocktail/mocktail.dart';

class MockPontoDeAplicacaoRepository extends Mock
    implements PontoDeAplicacaoRepository {}

void main() {
  late MockPontoDeAplicacaoRepository repository;

  final ponto = PontoDeAplicacao(
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
  });

  blocTest<PontoDeAplicacaoCubit, PontoDeAplicacaoState>(
    'emite [Loading, Loaded] com o ponto mapeado quando buscarAtual '
    'tem sucesso — o estado inicial já dispara o carregamento',
    setUp: () {
      when(() => repository.buscarAtual()).thenAnswer((_) async => ponto);
    },
    build: () => PontoDeAplicacaoCubit(repository),
    expect: () => [
      isA<PontoDeAplicacaoLoaded>().having(
        (s) => s.ponto.nomePonto,
        'ponto.nomePonto',
        ponto.nomePonto,
      ),
    ],
  );

  blocTest<PontoDeAplicacaoCubit, PontoDeAplicacaoState>(
    'emite [Error] com mensagem amigável quando buscarAtual falha '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => repository.buscarAtual()).thenThrow(Exception('offline'));
    },
    build: () => PontoDeAplicacaoCubit(repository),
    expect: () => [
      isA<PontoDeAplicacaoError>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );
}
