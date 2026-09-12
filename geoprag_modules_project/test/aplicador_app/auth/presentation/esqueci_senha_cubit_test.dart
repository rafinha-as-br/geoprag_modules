import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/auth/core/auth_repository.dart';
import 'package:geoprag_modules/aplicador_app/auth/presentation/auth_action_state.dart';
import 'package:geoprag_modules/aplicador_app/auth/presentation/esqueci_senha_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  blocTest<EsqueciSenhaCubit, AuthActionState<Null>>(
    'emite [Loading, Success] quando a solicitação de reset é aceita',
    setUp: () {
      when(
        () => repository.requestPasswordReset(email: any(named: 'email')),
      ).thenAnswer((_) async {});
    },
    build: () => EsqueciSenhaCubit(repository),
    act: (cubit) => cubit.submit(email: 'aplicador@example.com'),
    expect: () => [
      const AuthActionLoading<Null>(),
      const AuthActionSuccess<Null>(null),
    ],
    verify: (_) {
      verify(
        () => repository.requestPasswordReset(email: 'aplicador@example.com'),
      ).called(1);
    },
  );

  blocTest<EsqueciSenhaCubit, AuthActionState<Null>>(
    'emite [Loading, Failure] com mensagem amigável quando o repositório falha '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(
        () => repository.requestPasswordReset(email: any(named: 'email')),
      ).thenThrow(Exception('timeout de rede'));
    },
    build: () => EsqueciSenhaCubit(repository),
    act: (cubit) => cubit.submit(email: 'aplicador@example.com'),
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
