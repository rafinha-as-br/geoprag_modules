import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_auth_repository.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/auth_action_state.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/verificar_codigo_sub_admin_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminAuthRepository extends Mock implements AdminAuthRepository {}

void main() {
  late MockAdminAuthRepository repository;

  setUp(() {
    repository = MockAdminAuthRepository();
  });

  blocTest<VerificarCodigoSubAdminCubit, AuthActionState<Null>>(
    'emite [Loading, Success] quando o código informado é aceito',
    setUp: () {
      when(
        () => repository.verifyResetCode(code: any(named: 'code')),
      ).thenAnswer((_) async {});
    },
    build: () => VerificarCodigoSubAdminCubit(repository),
    act: (cubit) => cubit.submit(code: '123456'),
    expect: () => [
      const AuthActionLoading<Null>(),
      const AuthActionSuccess<Null>(null),
    ],
    verify: (_) {
      verify(() => repository.verifyResetCode(code: '123456')).called(1);
    },
  );

  blocTest<VerificarCodigoSubAdminCubit, AuthActionState<Null>>(
    'emite [Loading, Failure] com mensagem amigável quando o código é rejeitado '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(
        () => repository.verifyResetCode(code: any(named: 'code')),
      ).thenThrow(Exception('código expirado'));
    },
    build: () => VerificarCodigoSubAdminCubit(repository),
    act: (cubit) => cubit.submit(code: '000000'),
    expect: () => [
      const AuthActionLoading<Null>(),
      isA<AuthActionFailure<Null>>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );
}
