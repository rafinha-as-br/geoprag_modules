import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/auth/core/auth_exceptions.dart';
import 'package:geoprag_modules/aplicador_app/auth/core/auth_repository.dart';
import 'package:geoprag_modules/aplicador_app/auth/core/usuario.dart';
import 'package:geoprag_modules/aplicador_app/auth/presentation/auth_action_state.dart';
import 'package:geoprag_modules/aplicador_app/auth/presentation/login_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  const usuario = Usuario(
    id: 'u1',
    nome: 'João Silva',
    cpf: '000.000.000-00',
    tenantId: 'gaspar-sc',
  );

  setUp(() {
    repository = MockAuthRepository();
  });

  blocTest<LoginCubit, AuthActionState<Usuario>>(
    'emite [Loading, Success(usuario)] quando o login é bem-sucedido',
    setUp: () {
      when(
        () => repository.login(identifier: any(named: 'identifier'), senha: any(named: 'senha')),
      ).thenAnswer((_) async => usuario);
    },
    build: () => LoginCubit(repository),
    act: (cubit) => cubit.submit(identifier: usuario.cpf, senha: '123456'),
    expect: () => [
      const AuthActionLoading<Usuario>(),
      isA<AuthActionSuccess<Usuario>>().having((s) => s.data, 'data', usuario),
    ],
    verify: (_) {
      verify(
        () => repository.login(identifier: usuario.cpf, senha: '123456'),
      ).called(1);
    },
  );

  blocTest<LoginCubit, AuthActionState<Usuario>>(
    'emite [Loading, Failure] com mensagem amigável quando as credenciais são inválidas',
    setUp: () {
      when(
        () => repository.login(identifier: any(named: 'identifier'), senha: any(named: 'senha')),
      ).thenThrow(const InvalidCredentialsException());
    },
    build: () => LoginCubit(repository),
    act: (cubit) => cubit.submit(identifier: usuario.cpf, senha: 'senha-errada'),
    expect: () => [
      const AuthActionLoading<Usuario>(),
      isA<AuthActionFailure<Usuario>>().having(
        (s) => s.message,
        'message',
        'CPF/e-mail ou senha inválidos.',
      ),
    ],
  );

  blocTest<LoginCubit, AuthActionState<Usuario>>(
    'emite [Loading, Failure] com mensagem genérica para qualquer outro erro '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(
        () => repository.login(identifier: any(named: 'identifier'), senha: any(named: 'senha')),
      ).thenThrow(Exception('timeout de rede'));
    },
    build: () => LoginCubit(repository),
    act: (cubit) => cubit.submit(identifier: usuario.cpf, senha: '123456'),
    expect: () => [
      const AuthActionLoading<Usuario>(),
      isA<AuthActionFailure<Usuario>>().having(
        (s) => s.message,
        'message',
        'Não foi possível entrar. Tente novamente.',
      ),
    ],
  );
}
