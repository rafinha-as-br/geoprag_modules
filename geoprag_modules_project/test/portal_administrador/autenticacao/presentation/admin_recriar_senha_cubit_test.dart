import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_auth_repository.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_recriar_senha_cubit.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/auth_action_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminAuthRepository extends Mock implements AdminAuthRepository {}

void main() {
  late MockAdminAuthRepository repository;

  setUp(() {
    repository = MockAdminAuthRepository();
  });

  blocTest<AdminRecriarSenhaCubit, AuthActionState<Null>>(
    'emite [Loading, Success] quando a nova senha é aceita',
    setUp: () {
      when(
        () => repository.resetPassword(novaSenha: any(named: 'novaSenha')),
      ).thenAnswer((_) async {});
    },
    build: () => AdminRecriarSenhaCubit(repository),
    act: (cubit) => cubit.submit(novaSenha: 'nova-senha-123'),
    expect: () => [
      const AuthActionLoading<Null>(),
      const AuthActionSuccess<Null>(null),
    ],
    verify: (_) {
      verify(
        () => repository.resetPassword(novaSenha: 'nova-senha-123'),
      ).called(1);
    },
  );

  blocTest<AdminRecriarSenhaCubit, AuthActionState<Null>>(
    'emite [Loading, Failure] com mensagem amigável quando o repositório falha '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(
        () => repository.resetPassword(novaSenha: any(named: 'novaSenha')),
      ).thenThrow(Exception('falha de rede'));
    },
    build: () => AdminRecriarSenhaCubit(repository),
    act: (cubit) => cubit.submit(novaSenha: 'nova-senha-123'),
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
