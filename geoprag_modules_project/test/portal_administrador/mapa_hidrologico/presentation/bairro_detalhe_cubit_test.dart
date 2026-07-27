import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/core/bairro.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/core/corrego.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/core/corrego_repository.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/bairro_detalhe_cubit.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/bairro_detalhe_state.dart';
import 'package:mocktail/mocktail.dart';

class MockCorregoRepository extends Mock implements CorregoRepository {}

void main() {
  late MockCorregoRepository repository;

  const bairro = Bairro(
    id: 'b1',
    nome: 'Belchior',
    status: 'atrasado',
    diasSemAplicacao: 25,
    corregoIds: ['s1'],
  );

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

  blocTest<BairroDetalheCubit, BairroDetalheState>(
    'emite [Loaded] com o bairro e seus córregos agregados',
    setUp: () {
      when(() => repository.buscarBairroPorId('b1')).thenAnswer((_) async => bairro);
      when(
        () => repository.listarCorregosDoBairro('b1'),
      ).thenAnswer((_) async => [corrego]);
    },
    build: () => BairroDetalheCubit(repository, 'b1'),
    expect: () => [
      isA<BairroDetalheLoaded>()
          .having((s) => s.bairro.nome, 'bairro.nome', 'Belchior')
          .having((s) => s.bairro.corregos, 'bairro.corregos', hasLength(1)),
    ],
  );

  blocTest<BairroDetalheCubit, BairroDetalheState>(
    'emite [Error] com mensagem amigável quando o id não é encontrado '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(
        () => repository.buscarBairroPorId('inexistente'),
      ).thenThrow(StateError('Bairro "inexistente" não encontrado.'));
    },
    build: () => BairroDetalheCubit(repository, 'inexistente'),
    expect: () => [
      isA<BairroDetalheError>().having(
        (s) => s.message,
        'message',
        isNot(contains('StateError')),
      ),
    ],
  );
}
