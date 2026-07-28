import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/core/corrego.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/core/corrego_repository.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/corrego_detalhe_cubit.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/corrego_detalhe_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:geoprag_modules/src/errors/app_error_messages.dart';

class MockCorregoRepository extends Mock implements CorregoRepository {}

void main() {
  late MockCorregoRepository repository;

  const corrego = Corrego(
    id: 's1',
    nome: 'Córrego Belchior',
    bairro: 'Belchior',
    largura: 2.5,
    profundidade: 0.5,
    velocidade: 1.2,
  );

  setUp(() {
    repository = MockCorregoRepository();
  });

  blocTest<CorregoDetalheCubit, CorregoDetalheState>(
    'emite [Loaded] com as medições completas do córrego informado',
    setUp: () {
      when(() => repository.buscarPorId('s1')).thenAnswer((_) async => corrego);
    },
    build: () => CorregoDetalheCubit(repository, 's1'),
    expect: () => [
      isA<CorregoDetalheLoaded>().having(
        (s) => s.corrego.velocidade,
        'corrego.velocidade',
        1.2,
      ),
    ],
  );

  blocTest<CorregoDetalheCubit, CorregoDetalheState>(
    'emite [Error] com mensagem amigável quando o id não é encontrado '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(
        () => repository.buscarPorId('inexistente'),
      ).thenThrow(const EntidadeNaoEncontradaException('Córrego "inexistente" não encontrado.'));
    },
    build: () => CorregoDetalheCubit(repository, 'inexistente'),
    expect: () => [
      isA<CorregoDetalheError>().having(
        (s) => s.message,
        'message',
        'Córrego "inexistente" não encontrado.',
      ),
    ],
  );

  blocTest<CorregoDetalheCubit, CorregoDetalheState>(
    'emite [Error] com mensagem genérica (e loga) quando a exceção é '
    'inesperada, sem vazar detalhe técnico',
    setUp: () {
      when(() => repository.buscarPorId('inexistente')).thenThrow(Exception('offline'));
    },
    build: () => CorregoDetalheCubit(repository, 'inexistente'),
    expect: () => [
      isA<CorregoDetalheError>().having(
        (s) => s.message,
        'message',
        AppErrorMessages.carregamentoGenerico,
      ),
    ],
  );
}
