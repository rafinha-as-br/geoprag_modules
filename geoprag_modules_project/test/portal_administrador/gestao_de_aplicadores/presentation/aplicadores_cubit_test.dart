import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/core/aplicador.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/core/aplicador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/presentation/aplicadores_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/presentation/aplicadores_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAplicadorRepository extends Mock implements AplicadorRepository {}

void main() {
  late MockAplicadorRepository repository;

  final aplicador = Aplicador(
    id: '1',
    nome: 'João Silva',
    bairro: 'Belchior',
    status: 'ativo',
    dataCadastro: DateTime(2026, 5, 10),
    cpf: '111.111.111-11',
    telefone: '(47) 99111-1111',
    endereco: 'Rua das Flores, 50 - Belchior',
  );

  setUp(() {
    repository = MockAplicadorRepository();
  });

  blocTest<AplicadoresCubit, AplicadoresState>(
    'emite [Loaded] com os aplicadores mapeados para ViewModel',
    setUp: () {
      when(() => repository.listar()).thenAnswer((_) async => [aplicador]);
    },
    build: () => AplicadoresCubit(repository),
    expect: () => [
      isA<AplicadoresLoaded>().having(
        (s) => s.aplicadores.single.nome,
        'aplicadores.single.nome',
        'João Silva',
      ),
    ],
  );

  blocTest<AplicadoresCubit, AplicadoresState>(
    'emite [Error] com mensagem amigável quando o repositório falha '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => repository.listar()).thenThrow(Exception('offline'));
    },
    build: () => AplicadoresCubit(repository),
    expect: () => [
      isA<AplicadoresError>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );
}
