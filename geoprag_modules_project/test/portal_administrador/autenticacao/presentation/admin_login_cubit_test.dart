import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_auth_exceptions.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_auth_repository.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_login_cubit.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/auth_action_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminAuthRepository extends Mock implements AdminAuthRepository {}

void main() {
  late MockAdminAuthRepository repository;

  final account = AdminAccount(
    email: 'admin@gaspar.sc.gov.br',
    nome: 'Marcos Vieira',
    cpf: '123.456.789-00',
    dataNascimento: DateTime(1980, 5, 12),
    sexo: 'Masculino',
    dataCriacao: DateTime(2026, 1, 1),
    role: AdminRole.administrador,
  );

  setUp(() {
    repository = MockAdminAuthRepository();
  });

  blocTest<AdminLoginCubit, AuthActionState<AdminAccount>>(
    'emite [Loading, Success(account)] quando o login é bem-sucedido',
    setUp: () {
      when(
        () => repository.login(
          identifier: any(named: 'identifier'),
          senha: any(named: 'senha'),
        ),
      ).thenAnswer((_) async => account);
    },
    build: () => AdminLoginCubit(repository),
    act: (cubit) => cubit.submit(identifier: account.email, senha: '123456'),
    expect: () => [
      const AuthActionLoading<AdminAccount>(),
      isA<AuthActionSuccess<AdminAccount>>().having(
        (s) => s.data,
        'data',
        account,
      ),
    ],
  );

  blocTest<AdminLoginCubit, AuthActionState<AdminAccount>>(
    'emite [Loading, Failure] com mensagem específica quando as credenciais são inválidas',
    setUp: () {
      when(
        () => repository.login(
          identifier: any(named: 'identifier'),
          senha: any(named: 'senha'),
        ),
      ).thenThrow(const InvalidCredentialsException());
    },
    build: () => AdminLoginCubit(repository),
    act: (cubit) => cubit.submit(identifier: account.email, senha: 'errada'),
    expect: () => [
      const AuthActionLoading<AdminAccount>(),
      const AuthActionFailure<AdminAccount>('Credenciais inválidas.'),
    ],
  );

  blocTest<AdminLoginCubit, AuthActionState<AdminAccount>>(
    'emite [Loading, Failure] com mensagem genérica para qualquer outro erro '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(
        () => repository.login(
          identifier: any(named: 'identifier'),
          senha: any(named: 'senha'),
        ),
      ).thenThrow(Exception('timeout de rede'));
    },
    build: () => AdminLoginCubit(repository),
    act: (cubit) => cubit.submit(identifier: account.email, senha: '123456'),
    expect: () => [
      const AuthActionLoading<AdminAccount>(),
      const AuthActionFailure<AdminAccount>(
        'Não foi possível entrar. Tente novamente.',
      ),
    ],
  );
}
