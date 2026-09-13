import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/core/aplicador_ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/geolocalizacao_cubit.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/geolocalizacao_state.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:mocktail/mocktail.dart';

class MockAplicadorPontoDeAplicacaoRepository extends Mock
    implements AplicadorPontoDeAplicacaoRepository {}

void main() {
  late MockAplicadorPontoDeAplicacaoRepository repository;

  final ponto = PontoDeAplicacao(
    id: 'pa1',
    identificador: '#GAS1',
    nome: 'Córrego Gasparinho',
    bairro: 'Gasparinho',
    endereco: 'Rua Pedro Simon',
    numeroReferencia: 'Em frente ao nº 240',
    descricaoDoTrecho: 'Trecho de 400 m.',
    larguraMetros: 2,
    profundidadeMetros: 0.5,
    velocidadeMetrosPorSegundo: 0.4,
    dosagemMl: 120,
    distanciaEntreSubpontosMetros: 75,
    quantidadeDeSubpontos: 8,
    aplicadorId: '1',
    estado: EstadoPontoDeAplicacao.ativa,
  );

  setUp(() {
    repository = MockAplicadorPontoDeAplicacaoRepository();
  });

  blocTest<GeolocalizacaoCubit, GeolocalizacaoState>(
    'emite [Loaded] com dentroDoRaio false e a distância cadastrada do ponto',
    setUp: () {
      when(() => repository.buscarPorId('pa1')).thenAnswer((_) async => ponto);
    },
    build: () => GeolocalizacaoCubit(repository, 'pa1'),
    expect: () => [
      isA<GeolocalizacaoLoaded>()
          .having((s) => s.dentroDoRaio, 'dentroDoRaio', false)
          .having(
            (s) => s.ponto.distanciaEntreSubpontosMetros,
            'distanciaEntreSubpontosMetros',
            75,
          ),
    ],
  );

  blocTest<GeolocalizacaoCubit, GeolocalizacaoState>(
    'emite [Error] com mensagem amigável quando falha ao carregar '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => repository.buscarPorId('pa1'))
          .thenAnswer((_) async => throw Exception('offline'));
    },
    build: () => GeolocalizacaoCubit(repository, 'pa1'),
    expect: () => [
      isA<GeolocalizacaoError>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );

  blocTest<GeolocalizacaoCubit, GeolocalizacaoState>(
    'confirmarChegada muda dentroDoRaio para true preservando o mesmo ponto',
    setUp: () {
      when(() => repository.buscarPorId('pa1')).thenAnswer((_) async => ponto);
    },
    build: () => GeolocalizacaoCubit(repository, 'pa1'),
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      cubit.confirmarChegada();
    },
    expect: () => [
      isA<GeolocalizacaoLoaded>().having((s) => s.dentroDoRaio, 'dentroDoRaio', false),
      isA<GeolocalizacaoLoaded>()
          .having((s) => s.dentroDoRaio, 'dentroDoRaio', true)
          .having((s) => s.ponto.id, 'ponto.id', 'pa1'),
    ],
  );

  blocTest<GeolocalizacaoCubit, GeolocalizacaoState>(
    'confirmarChegada não emite nada se o estado atual não for Loaded',
    setUp: () {
      when(() => repository.buscarPorId('pa1'))
          .thenAnswer((_) async => throw Exception('offline'));
    },
    build: () => GeolocalizacaoCubit(repository, 'pa1'),
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      cubit.confirmarChegada();
    },
    expect: () => [isA<GeolocalizacaoError>()],
  );
}
