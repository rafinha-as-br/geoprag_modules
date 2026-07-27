import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/applications/core/aplicacao.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/core/aplicacao_mapa_repository.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/aplicacao_mapa_cubit.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/aplicacao_mapa_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAplicacaoMapaRepository extends Mock implements AplicacaoMapaRepository {}

void main() {
  late MockAplicacaoMapaRepository repository;

  final aplicacao = Aplicacao(
    id: 'a1',
    data: DateTime(2026, 5, 3),
    lat: -26.9328,
    lng: -48.9554,
    dosagem: 10.5,
    aplicadorId: '1',
  );

  setUp(() {
    repository = MockAplicacaoMapaRepository();
  });

  blocTest<AplicacaoMapaCubit, AplicacaoMapaState>(
    'emite [Loaded] com a aplicação do id informado',
    setUp: () {
      when(() => repository.buscarPorId('a1')).thenAnswer((_) async => aplicacao);
    },
    build: () => AplicacaoMapaCubit(repository, 'a1'),
    expect: () => [
      isA<AplicacaoMapaLoaded>().having(
        (s) => s.aplicacao.aplicadorId,
        'aplicacao.aplicadorId',
        '1',
      ),
    ],
  );

  blocTest<AplicacaoMapaCubit, AplicacaoMapaState>(
    'emite [Error] com mensagem amigável quando o id não é encontrado '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(
        () => repository.buscarPorId('inexistente'),
      ).thenThrow(StateError('Aplicação "inexistente" não encontrada.'));
    },
    build: () => AplicacaoMapaCubit(repository, 'inexistente'),
    expect: () => [
      isA<AplicacaoMapaError>().having(
        (s) => s.message,
        'message',
        isNot(contains('StateError')),
      ),
    ],
  );
}
