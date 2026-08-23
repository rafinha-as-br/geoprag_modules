import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/core/bairro.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/core/corrego_repository.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/bairros_cubit.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/bairros_state.dart';
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

  setUp(() {
    repository = MockCorregoRepository();
  });

  blocTest<BairrosCubit, BairrosState>(
    'emite [Loaded] com os bairros mapeados para ViewModel',
    setUp: () {
      when(() => repository.listarBairros()).thenAnswer((_) async => [bairro]);
    },
    build: () => BairrosCubit(repository),
    expect: () => [
      isA<BairrosLoaded>().having(
        (s) => s.bairros.single.nome,
        'bairros.single.nome',
        'Belchior',
      ),
    ],
  );

  blocTest<BairrosCubit, BairrosState>(
    'emite [Error] com mensagem amigável quando o repositório falha '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => repository.listarBairros()).thenAnswer((_) async => throw Exception('offline'));
    },
    build: () => BairrosCubit(repository),
    expect: () => [
      isA<BairrosError>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );
}
