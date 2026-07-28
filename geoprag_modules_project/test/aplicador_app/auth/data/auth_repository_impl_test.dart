import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/auth/core/auth_exceptions.dart';
import 'package:geoprag_modules/aplicador_app/auth/data/auth_repository_impl.dart';
import 'package:geoprag_modules/aplicador_app/auth/data/mock_usuarios.dart';

void main() {
  late AuthRepositoryImpl repository;

  setUp(() {
    repository = AuthRepositoryImpl();
  });

  group('AuthRepositoryImpl.login', () {
    test('retorna o Usuario quando CPF e senha conferem com mockUsers', () async {
      final usuario = mockUsers.first;

      final result = await repository.login(
        identifier: usuario.cpf,
        senha: mockUserSenha,
      );

      expect(result.id, usuario.id);
      expect(result.nome, usuario.nome);
      expect(result.cpf, usuario.cpf);
      expect(result.tenantId, usuario.tenantId);
    });

    test('remove espaços em branco do identifier antes de comparar', () async {
      final usuario = mockUsers.first;

      final result = await repository.login(
        identifier: '  ${usuario.cpf}  ',
        senha: mockUserSenha,
      );

      expect(result.cpf, usuario.cpf);
    });

    test('lança InvalidCredentialsException quando o CPF não existe em mockUsers', () {
      expect(
        () => repository.login(identifier: '999.999.999-99', senha: mockUserSenha),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });

    test('lança InvalidCredentialsException quando a senha não confere', () {
      final usuario = mockUsers.first;

      expect(
        () => repository.login(identifier: usuario.cpf, senha: 'senha-errada'),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });
  });

  group('AuthRepositoryImpl — demais operações mockadas', () {
    test('logout completa sem lançar exceção', () async {
      await expectLater(repository.logout(), completes);
    });

    test('requestPasswordReset completa sem lançar exceção', () async {
      await expectLater(
        repository.requestPasswordReset(email: 'aplicador@example.com'),
        completes,
      );
    });

    test('verifyResetCode completa sem lançar exceção', () async {
      await expectLater(
        repository.verifyResetCode(code: '123456'),
        completes,
      );
    });

    test('resetPassword completa sem lançar exceção', () async {
      await expectLater(
        repository.resetPassword(novaSenha: 'nova-senha-123'),
        completes,
      );
    });
  });
}
