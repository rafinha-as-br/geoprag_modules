import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_auth_exceptions.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/data/admin_auth_repository_impl.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/data/mock_admin_accounts.dart';

void main() {
  late AdminAuthRepositoryImpl repository;

  setUp(() {
    repository = AdminAuthRepositoryImpl();
  });

  group('login', () {
    test('retorna a conta quando e-mail e senha conferem', () async {
      final account = mockAdminAccounts.first;

      final result = await repository.login(
        identifier: account.email,
        senha: mockAdminSenha,
      );

      expect(result.email, account.email);
      expect(result.role, account.role);
    });

    test('é case-insensitive para o e-mail', () async {
      final account = mockAdminAccounts.first;

      final result = await repository.login(
        identifier: account.email.toUpperCase(),
        senha: mockAdminSenha,
      );

      expect(result.email, account.email);
    });

    test('remove espaços em branco do identifier antes de comparar', () async {
      final account = mockAdminAccounts.first;

      final result = await repository.login(
        identifier: '  ${account.email}  ',
        senha: mockAdminSenha,
      );

      expect(result.email, account.email);
    });

    test('lança InvalidCredentialsException para e-mail inexistente', () {
      expect(
        () => repository.login(
          identifier: 'ninguem@gaspar.sc.gov.br',
          senha: mockAdminSenha,
        ),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });

    test('lança InvalidCredentialsException quando a senha não confere', () {
      final account = mockAdminAccounts.first;

      expect(
        () =>
            repository.login(identifier: account.email, senha: 'senha-errada'),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });
  });

  group('findByEmail', () {
    test(
      'retorna a conta correspondente ao e-mail (case-insensitive)',
      () async {
        final account = mockAdminAccounts.firstWhere(
          (a) => a.role == AdminRole.subAdministrador,
        );

        final result = await repository.findByEmail(
          account.email.toUpperCase(),
        );

        expect(result, isNotNull);
        expect(result!.role, AdminRole.subAdministrador);
      },
    );

    test(
      'retorna null quando o e-mail não existe em mockAdminAccounts',
      () async {
        final result = await repository.findByEmail('ninguem@gaspar.sc.gov.br');
        expect(result, isNull);
      },
    );
  });

  group('demais operações mockadas', () {
    test('logout completa sem lançar exceção', () async {
      await expectLater(repository.logout(), completes);
    });

    test('resetPassword completa sem lançar exceção', () async {
      await expectLater(
        repository.resetPassword(novaSenha: 'nova-senha-123'),
        completes,
      );
    });
  });
}
