import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/auth/core/auth_repository.dart';
import 'package:geoprag_modules/aplicador_app/auth/core/usuario.dart';
import 'package:geoprag_modules/aplicador_app/auth/presentation/aplicador_sessao_cubit.dart';
import 'package:geoprag_modules/aplicador_app/auth/presentation/aplicador_sessao_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  const usuario = Usuario(
    id: 'u-77',
    nome: 'João Silva',
    tenantId: 'gaspar-sc',
  );

  setUp(() {
    repository = MockAuthRepository();
  });

  blocTest<AplicadorSessaoCubit, AplicadorSessaoState>(
    'estado inicial é SemAcesso',
    build: () => AplicadorSessaoCubit(repository),
    verify: (cubit) => expect(cubit.state, isA<AplicadorSessaoSemAcesso>()),
  );

  blocTest<AplicadorSessaoCubit, AplicadorSessaoState>(
    'restaurar emite Autenticada quando há sessão guardada',
    setUp: () {
      when(() => repository.sessaoAtual()).thenAnswer((_) async => usuario);
    },
    build: () => AplicadorSessaoCubit(repository),
    act: (cubit) => cubit.restaurar(),
    expect: () => [
      isA<AplicadorSessaoAutenticada>().having(
        (s) => s.usuario.id,
        'usuario.id',
        'u-77',
      ),
    ],
  );

  blocTest<AplicadorSessaoCubit, AplicadorSessaoState>(
    'restaurar sem sessão guardada não emite nada',
    setUp: () {
      when(() => repository.sessaoAtual()).thenAnswer((_) async => null);
    },
    build: () => AplicadorSessaoCubit(repository),
    act: (cubit) => cubit.restaurar(),
    expect: () => <AplicadorSessaoState>[],
  );

  blocTest<AplicadorSessaoCubit, AplicadorSessaoState>(
    'restaurar com falha de leitura segue sem sessão (o app pede o login)',
    setUp: () {
      when(() => repository.sessaoAtual()).thenThrow(Exception('storage'));
    },
    build: () => AplicadorSessaoCubit(repository),
    act: (cubit) => cubit.restaurar(),
    expect: () => <AplicadorSessaoState>[],
  );

  blocTest<AplicadorSessaoCubit, AplicadorSessaoState>(
    'iniciarSessao emite Autenticada com o usuário do login',
    build: () => AplicadorSessaoCubit(repository),
    act: (cubit) => cubit.iniciarSessao(usuario),
    expect: () => [
      isA<AplicadorSessaoAutenticada>().having(
        (s) => s.usuario.tenantId,
        'usuario.tenantId',
        'gaspar-sc',
      ),
    ],
  );

  blocTest<AplicadorSessaoCubit, AplicadorSessaoState>(
    'encerrarSessao apaga a sessão do aparelho e emite SemAcesso',
    setUp: () {
      when(() => repository.logout()).thenAnswer((_) async {});
    },
    build: () => AplicadorSessaoCubit(repository),
    seed: () => const AplicadorSessaoAutenticada(usuario),
    act: (cubit) => cubit.encerrarSessao(),
    expect: () => [isA<AplicadorSessaoSemAcesso>()],
    verify: (_) => verify(() => repository.logout()).called(1),
  );

  blocTest<AplicadorSessaoCubit, AplicadorSessaoState>(
    'encerrarSessao emite SemAcesso mesmo se apagar o armazenamento falhar',
    setUp: () {
      when(() => repository.logout()).thenThrow(Exception('storage'));
    },
    build: () => AplicadorSessaoCubit(repository),
    seed: () => const AplicadorSessaoAutenticada(usuario),
    act: (cubit) => cubit.encerrarSessao(),
    expect: () => [isA<AplicadorSessaoSemAcesso>()],
  );

  blocTest<AplicadorSessaoCubit, AplicadorSessaoState>(
    'sessaoPerdida emite SemAcesso sem chamar o logout (a API já apagou os tokens)',
    build: () => AplicadorSessaoCubit(repository),
    seed: () => const AplicadorSessaoAutenticada(usuario),
    act: (cubit) => cubit.sessaoPerdida(),
    expect: () => [isA<AplicadorSessaoSemAcesso>()],
    verify: (_) => verifyNever(() => repository.logout()),
  );
}
