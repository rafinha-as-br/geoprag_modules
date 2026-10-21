import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/auth/core/auth_repository.dart';
import 'package:geoprag_modules/aplicador_app/auth/core/usuario.dart';
import 'package:geoprag_modules/aplicador_app/auth/presentation/auth_action_state.dart';
import 'package:geoprag_modules/aplicador_app/auth/presentation/login_cubit.dart';
import 'package:geoprag_modules/src/api/api_exceptions.dart';
import 'package:geoprag_modules/src/errors/app_error_messages.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  void falhaCom(Exception erro) => when(
    () => repository.login(
      identifier: any(named: 'identifier'),
      senha: any(named: 'senha'),
    ),
  ).thenThrow(erro);

  blocTest<LoginCubit, AuthActionState<Usuario>>(
    'credenciais recusadas pelo servidor mostram a mensagem dele',
    setUp: () =>
        falhaCom(const NaoAutenticadoException('Credenciais inválidas')),
    build: () => LoginCubit(repository),
    act: (cubit) => cubit.submit(identifier: 'x', senha: 'y'),
    expect: () => [
      const AuthActionLoading<Usuario>(),
      const AuthActionFailure<Usuario>('Credenciais inválidas'),
    ],
  );

  blocTest<LoginCubit, AuthActionState<Usuario>>(
    'usuário desativado mostra a mensagem do servidor',
    setUp: () => falhaCom(const AcessoNegadoException('Usuário desativado')),
    build: () => LoginCubit(repository),
    act: (cubit) => cubit.submit(identifier: 'x', senha: 'y'),
    expect: () => [
      const AuthActionLoading<Usuario>(),
      const AuthActionFailure<Usuario>('Usuário desativado'),
    ],
  );

  blocTest<LoginCubit, AuthActionState<Usuario>>(
    'sem rede mostra a mensagem amigável da camada HTTP',
    setUp: () =>
        falhaCom(const FalhaDeConexaoException(AppErrorMessages.semConexao)),
    build: () => LoginCubit(repository),
    act: (cubit) => cubit.submit(identifier: 'x', senha: 'y'),
    expect: () => [
      const AuthActionLoading<Usuario>(),
      const AuthActionFailure<Usuario>(AppErrorMessages.semConexao),
    ],
  );
}
