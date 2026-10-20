import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/geoprag_modules.dart';
import 'package:geoprag_modules/src/entities/usuario.dart';

UsuarioDto _dto({
  PerfilDto perfil = PerfilDto.aplicador,
  StatusUsuarioDto status = StatusUsuarioDto.ativo,
}) => UsuarioDto(
  id: 'u-0001',
  nome: 'Fulano de Tal',
  perfil: perfil,
  tenantId: 'gaspar-sc',
  email: 'fulano@exemplo.com',
  status: status,
);

void main() {
  group('AuthMappers.paraUsuarioDoAplicador', () {
    test('carrega id, nome e tenantId do servidor', () {
      final usuario = AuthMappers.paraUsuarioDoAplicador(_dto());

      expect(usuario.id, 'u-0001');
      expect(usuario.nome, 'Fulano de Tal');
      expect(usuario.tenantId, 'gaspar-sc');
    });

    test('cpf só existe quando o app o informa', () {
      expect(AuthMappers.paraUsuarioDoAplicador(_dto()).cpf, isNull);
      expect(
        AuthMappers.paraUsuarioDoAplicador(_dto(), cpf: '12345678900').cpf,
        '12345678900',
      );
    });

    test('recusa DTO que não é de aplicador', () {
      for (final perfil in [
        PerfilDto.administrador,
        PerfilDto.subAdministrador,
      ]) {
        expect(
          () => AuthMappers.paraUsuarioDoAplicador(_dto(perfil: perfil)),
          throwsArgumentError,
        );
      }
    });
  });

  group('AuthMappers.paraAdminAccount', () {
    test('administrador: id, tenantId, nome, e-mail, cargo e status', () {
      final conta = AuthMappers.paraAdminAccount(
        _dto(perfil: PerfilDto.administrador),
      );

      expect(conta.id, 'u-0001');
      expect(conta.tenantId, 'gaspar-sc');
      expect(conta.nome, 'Fulano de Tal');
      expect(conta.email, 'fulano@exemplo.com');
      expect(conta.role, AdminRole.administrador);
      expect(conta.status, UsuarioStatus.ativo);
    });

    test('sub-administrador e acesso desativado', () {
      final conta = AuthMappers.paraAdminAccount(
        _dto(
          perfil: PerfilDto.subAdministrador,
          status: StatusUsuarioDto.desativado,
        ),
      );

      expect(conta.role, AdminRole.subAdministrador);
      expect(conta.status, UsuarioStatus.desativado);
      expect(conta.ativo, isFalse);
    });

    test('dados cadastrais que o contrato não traz ficam sem valor', () {
      final conta = AuthMappers.paraAdminAccount(
        _dto(perfil: PerfilDto.administrador),
      );

      expect(conta.cpf, isEmpty);
      expect(conta.sexo, isEmpty);
      expect(conta.dataNascimento, AuthMappers.dataNaoInformada);
      expect(conta.dataCriacao, AuthMappers.dataNaoInformada);
    });

    test('recusa DTO de aplicador', () {
      expect(() => AuthMappers.paraAdminAccount(_dto()), throwsArgumentError);
    });
  });

  group('entidades de sessão carregam id e tenantId (GEOPRAG-186)', () {
    test('AdminAccount.copyWith preserva id e tenantId', () {
      final conta = AuthMappers.paraAdminAccount(
        _dto(perfil: PerfilDto.administrador),
      );

      final copia = conta.copyWith(nome: 'Outro Nome');

      expect(copia.id, 'u-0001');
      expect(copia.tenantId, 'gaspar-sc');
      expect(copia.nome, 'Outro Nome');
    });

    test('as contas simuladas têm id único e tenantId', () {
      final ids = mockAdminAccounts.map((c) => c.id).toList();

      expect(ids.toSet().length, ids.length);
      expect(mockAdminAccounts.every((c) => c.tenantId.isNotEmpty), isTrue);
    });
  });
}
