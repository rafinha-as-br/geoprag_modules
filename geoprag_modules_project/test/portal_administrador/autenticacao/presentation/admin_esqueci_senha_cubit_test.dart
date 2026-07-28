import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_auth_repository.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_esqueci_senha_cubit.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/auth_action_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminAuthRepository extends Mock implements AdminAuthRepository {}

void main() {
  late MockAdminAuthRepository repository;

  setUp(() {
    repository = MockAdminAuthRepository();
  });

  blocTest<AdminEsqueciSenhaCubit, AuthActionState<AdminRole>>(
    'quando a conta existe, emite [Loading, Success(role)] com o papel da conta',
    setUp: () {
      when(() => repository.findByEmail('celia.ramos@gaspar.sc.gov.br')).thenAnswer(
        (_) async => const AdminAccount(
          email: 'celia.ramos@gaspar.sc.gov.br',
          nome: 'Célia Ramos',
          role: AdminRole.subAdministrador,
        ),
      );
    },
    build: () => AdminEsqueciSenhaCubit(repository),
    act: (cubit) => cubit.submit(email: 'celia.ramos@gaspar.sc.gov.br'),
    expect: () => [
      const AuthActionLoading<AdminRole>(),
      const AuthActionSuccess<AdminRole>(AdminRole.subAdministrador),
    ],
  );

  blocTest<AdminEsqueciSenhaCubit, AuthActionState<AdminRole>>(
    'quando a conta não existe, assume papel subAdministrador por padrão',
    setUp: () {
      when(
        () => repository.findByEmail('ninguem@gaspar.sc.gov.br'),
      ).thenAnswer((_) async => null);
    },
    build: () => AdminEsqueciSenhaCubit(repository),
    act: (cubit) => cubit.submit(email: 'ninguem@gaspar.sc.gov.br'),
    expect: () => [
      const AuthActionLoading<AdminRole>(),
      const AuthActionSuccess<AdminRole>(AdminRole.subAdministrador),
    ],
  );

  blocTest<AdminEsqueciSenhaCubit, AuthActionState<AdminRole>>(
    'emite [Loading, Failure] com mensagem amigável quando o repositório falha '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(
        () => repository.findByEmail(any()),
      ).thenThrow(Exception('offline'));
    },
    build: () => AdminEsqueciSenhaCubit(repository),
    act: (cubit) => cubit.submit(email: 'admin@gaspar.sc.gov.br'),
    expect: () => [
      const AuthActionLoading<AdminRole>(),
      isA<AuthActionFailure<AdminRole>>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );
}
