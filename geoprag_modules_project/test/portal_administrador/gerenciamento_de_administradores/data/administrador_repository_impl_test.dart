import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/data/mock_admin_accounts.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/data/administrador_repository_impl.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';

void main() {
  late AdministradorRepositoryImpl repository;

  setUp(() {
    repository = AdministradorRepositoryImpl();
  });

  tearDown(() {
    mockAdminAccounts.removeWhere((conta) => conta.email == 'nova@gaspar.sc.gov.br');
  });

  test('criar adiciona a conta como Sub-Administrador, mesmo cargo não sendo informado', () async {
    final conta = await repository.criar(
      email: 'nova@gaspar.sc.gov.br',
      nome: 'Nova Conta',
      cpf: '123.456.789-00',
      dataNascimento: DateTime(1990, 1, 1),
      sexo: 'Feminino',
    );

    expect(conta.role, AdminRole.subAdministrador);
    expect(mockAdminAccounts, contains(conta));
  });

  test('criar lança EntidadeDuplicadaException para e-mail já cadastrado', () async {
    final emailExistente = mockAdminAccounts.first.email;

    expect(
      () => repository.criar(
        email: emailExistente,
        nome: 'Outro Nome',
        cpf: '123.456.789-00',
        dataNascimento: DateTime(1990, 1, 1),
        sexo: 'Feminino',
      ),
      throwsA(isA<EntidadeDuplicadaException>()),
    );
  });
}
