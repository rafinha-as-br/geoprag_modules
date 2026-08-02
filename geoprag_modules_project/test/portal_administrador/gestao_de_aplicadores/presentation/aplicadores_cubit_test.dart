import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/core/aplicador.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/core/aplicador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/presentation/aplicadores_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/presentation/aplicadores_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geoprag_modules/src/entities/usuario.dart';

class MockAplicadorRepository extends Mock implements AplicadorRepository {}

void main() {
  late MockAplicadorRepository repository;

  final aplicador = Aplicador(
    id: '1',
    nome: 'João Silva',
    bairro: 'Belchior',
    status: UsuarioStatus.ativo,
    dataCriacao: DateTime(2026, 5, 10),
    email: 'joao.silva@email.com',
    cpf: '111.111.111-11',
    dataNascimento: DateTime(1988, 4, 12),
    sexo: 'Masculino',
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

  final aplicadorDesativado = Aplicador(
    id: '2',
    nome: 'Carlos Lima',
    bairro: 'Gasparinho',
    status: UsuarioStatus.desativado,
    dataCriacao: DateTime(2026, 6, 15),
    email: 'carlos.lima@email.com',
    cpf: '333.333.333-33',
    dataNascimento: DateTime(1975, 11, 30),
    sexo: 'Masculino',
    telefone: '(47) 99333-3333',
    endereco: 'Rua do Bosque, 20 - Gasparinho',
  );

  blocTest<AplicadoresCubit, AplicadoresState>(
    'alterarFiltro atualiza aplicadoresFiltrados e limpa a seleção atual',
    setUp: () {
      when(
        () => repository.listar(),
      ).thenAnswer((_) async => [aplicador, aplicadorDesativado]);
    },
    build: () => AplicadoresCubit(repository),
    act: (cubit) async {
      // Aguarda o carregamento inicial do construtor terminar antes de
      // mutar o estado — do contrário a chamada corre com o Cubit ainda
      // em AplicadoresLoading e é ignorada (no-op).
      await Future<void>.delayed(Duration.zero);
      cubit.alternarSelecao('1');
      cubit.alterarFiltro(FiltroStatusAplicador.ativos);
    },
    skip: 1,
    expect: () => [
      isA<AplicadoresLoaded>(), // seleção de '1'
      isA<AplicadoresLoaded>()
          .having((s) => s.selecionados, 'selecionados', isEmpty)
          .having(
            (s) => s.aplicadoresFiltrados.map((a) => a.id),
            'aplicadoresFiltrados',
            ['1'],
          ),
    ],
  );

  blocTest<AplicadoresCubit, AplicadoresState>(
    'alternarSelecao adiciona e remove o id da seleção',
    setUp: () {
      when(() => repository.listar()).thenAnswer((_) async => [aplicador]);
    },
    build: () => AplicadoresCubit(repository),
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      cubit.alternarSelecao('1');
      cubit.alternarSelecao('1');
    },
    skip: 1,
    expect: () => [
      isA<AplicadoresLoaded>().having(
        (s) => s.selecionados,
        'selecionados',
        {'1'},
      ),
      isA<AplicadoresLoaded>().having(
        (s) => s.selecionados,
        'selecionados',
        isEmpty,
      ),
    ],
  );

  blocTest<AplicadoresCubit, AplicadoresState>(
    'ativarSelecionados chama o repositório para cada id e recarrega a lista',
    setUp: () {
      when(
        () => repository.listar(),
      ).thenAnswer((_) async => [aplicador, aplicadorDesativado]);
      when(() => repository.ativar(any())).thenAnswer((_) async {});
    },
    build: () => AplicadoresCubit(repository),
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      cubit.alternarSelecao('2');
      await cubit.ativarSelecionados();
    },
    verify: (_) {
      verify(() => repository.ativar('2')).called(1);
      verifyNever(() => repository.desativar(any()));
    },
  );

  blocTest<AplicadoresCubit, AplicadoresState>(
    'desativarSelecionados emite Error quando o repositório falha',
    setUp: () {
      when(() => repository.listar()).thenAnswer((_) async => [aplicador]);
      when(
        () => repository.desativar(any()),
      ).thenAnswer((_) async => throw Exception('falha de rede'));
    },
    build: () => AplicadoresCubit(repository),
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      cubit.alternarSelecao('1');
      await cubit.desativarSelecionados();
    },
    skip: 3, // Loaded inicial, seleção do id '1', e o flag processando=true
    expect: () => [
      isA<AplicadoresError>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );
}
