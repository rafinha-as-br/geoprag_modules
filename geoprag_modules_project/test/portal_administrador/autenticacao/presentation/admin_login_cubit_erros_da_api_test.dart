import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_auth_repository.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_login_cubit.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/auth_action_state.dart';
import 'package:geoprag_modules/src/api/api_exceptions.dart';
import 'package:geoprag_modules/src/errors/app_error_messages.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminAuthRepository extends Mock implements AdminAuthRepository {}

void main() {
  late MockAdminAuthRepository repository;

  setUp(() {
    repository = MockAdminAuthRepository();
  });

  void falhaCom(Exception erro) => when(
    () => repository.login(
      identifier: any(named: 'identifier'),
      senha: any(named: 'senha'),
    ),
  ).thenThrow(erro);

  blocTest<AdminLoginCubit, AuthActionState<AdminAccount>>(
    'credenciais recusadas pelo servidor mostram a mensagem dele',
    setUp: () =>
        falhaCom(const NaoAutenticadoException('Credenciais inválidas')),
    build: () => AdminLoginCubit(repository),
    act: (cubit) => cubit.submit(identifier: 'x', senha: 'y'),
    expect: () => [
      const AuthActionLoading<AdminAccount>(),
      const AuthActionFailure<AdminAccount>('Credenciais inválidas'),
    ],
  );

  blocTest<AdminLoginCubit, AuthActionState<AdminAccount>>(
    'usuário desativado mostra a mensagem do servidor',
    setUp: () => falhaCom(const AcessoNegadoException('Usuário desativado')),
    build: () => AdminLoginCubit(repository),
    act: (cubit) => cubit.submit(identifier: 'x', senha: 'y'),
    expect: () => [
      const AuthActionLoading<AdminAccount>(),
      const AuthActionFailure<AdminAccount>('Usuário desativado'),
    ],
  );

  blocTest<AdminLoginCubit, AuthActionState<AdminAccount>>(
    'sem rede mostra a mensagem amigável da camada HTTP',
    setUp: () =>
        falhaCom(const FalhaDeConexaoException(AppErrorMessages.semConexao)),
    build: () => AdminLoginCubit(repository),
    act: (cubit) => cubit.submit(identifier: 'x', senha: 'y'),
    expect: () => [
      const AuthActionLoading<AdminAccount>(),
      const AuthActionFailure<AdminAccount>(AppErrorMessages.semConexao),
    ],
  );
}
