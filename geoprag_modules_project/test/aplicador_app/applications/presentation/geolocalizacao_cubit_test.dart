import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/entities/aplicacao.dart';
import 'package:geoprag_modules/aplicador_app/applications/core/aplicacao_repository.dart';
import 'package:geoprag_modules/aplicador_app/applications/presentation/geolocalizacao_cubit.dart';
import 'package:geoprag_modules/aplicador_app/applications/presentation/geolocalizacao_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAplicacaoRepository extends Mock implements AplicacaoRepository {}

void main() {
  late MockAplicacaoRepository repository;

  final aplicacao = Aplicacao(
    id: 'a1',
    data: DateTime(2026, 5, 3),
    lat: -26.9328,
    lng: -48.9554,
    dosagem: 10.5,
    aplicadorId: '1',
  );

  setUp(() {
    repository = MockAplicacaoRepository();
  });

  blocTest<GeolocalizacaoCubit, GeolocalizacaoState>(
    'emite [Loaded] com dentroDoRaio false ao carregar a aplicação',
    setUp: () {
      when(() => repository.buscarAtual('1')).thenAnswer((_) async => aplicacao);
    },
    build: () => GeolocalizacaoCubit(repository, '1'),
    expect: () => [
      isA<GeolocalizacaoLoaded>().having(
        (s) => s.dentroDoRaio,
        'dentroDoRaio',
        false,
      ),
    ],
  );

  blocTest<GeolocalizacaoCubit, GeolocalizacaoState>(
    'emite [Error] com mensagem amigável quando falha ao carregar '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => repository.buscarAtual('1')).thenThrow(Exception('offline'));
    },
    build: () => GeolocalizacaoCubit(repository, '1'),
    expect: () => [
      isA<GeolocalizacaoError>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );

  blocTest<GeolocalizacaoCubit, GeolocalizacaoState>(
    'confirmarChegada muda dentroDoRaio para true preservando a mesma aplicação',
    setUp: () {
      when(() => repository.buscarAtual('1')).thenAnswer((_) async => aplicacao);
    },
    build: () => GeolocalizacaoCubit(repository, '1'),
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      cubit.confirmarChegada();
    },
    expect: () => [
      isA<GeolocalizacaoLoaded>().having((s) => s.dentroDoRaio, 'dentroDoRaio', false),
      isA<GeolocalizacaoLoaded>()
          .having((s) => s.dentroDoRaio, 'dentroDoRaio', true)
          .having((s) => s.aplicacao.id, 'aplicacao.id', 'a1'),
    ],
  );

  blocTest<GeolocalizacaoCubit, GeolocalizacaoState>(
    'confirmarChegada não emite nada se o estado atual não for Loaded '
    '(ex: ainda carregando ou em erro)',
    setUp: () {
      when(() => repository.buscarAtual('1')).thenThrow(Exception('offline'));
    },
    build: () => GeolocalizacaoCubit(repository, '1'),
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      cubit.confirmarChegada();
    },
    expect: () => [isA<GeolocalizacaoError>()],
  );
}
