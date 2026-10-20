import '../../../aplicador_app/auth/core/usuario.dart' as aplicador;
import '../../../portal_administrador/autenticacao/core/admin_account.dart';
import '../../entities/usuario.dart' show UsuarioStatus;
import 'usuario_dto.dart';

/// Conversão [UsuarioDto] → entidades de sessão. Fica fora do domínio: as
/// entidades não conhecem JSON nem DTO (GEOPRAG-186).
class AuthMappers {
  const AuthMappers._();

  /// Data usada nos campos cadastrais que o contrato v0 não devolve
  /// (`dataNascimento` e `dataCriacao` do [AdminAccount]).
  static final DateTime dataNaoInformada = DateTime.utc(1970);

  /// [UsuarioDto] de um aplicador → [aplicador.Usuario] da sessão do App
  /// Aplicador.
  ///
  /// O contrato não devolve CPF; [cpf] só deve ser informado quando o app o
  /// conhece (ex.: o CPF digitado no login).
  ///
  /// Lança [ArgumentError] se o DTO não for de um aplicador.
  static aplicador.Usuario paraUsuarioDoAplicador(
    UsuarioDto dto, {
    String? cpf,
  }) {
    if (dto.perfil != PerfilDto.aplicador) {
      throw ArgumentError.value(
        dto.perfil.valorJson,
        'dto.perfil',
        'Esperado um usuário com perfil APLICADOR.',
      );
    }
    return aplicador.Usuario(
      id: dto.id,
      nome: dto.nome,
      cpf: cpf,
      tenantId: dto.tenantId,
    );
  }

  /// [UsuarioDto] de um administrador ou sub-administrador → [AdminAccount]
  /// da sessão do portal.
  ///
  /// O contrato v0 devolve só `id`, `nome`, `perfil`, `tenantId`, `email` e
  /// `status`. Os dados cadastrais que ele não traz ficam **sem valor**:
  /// `cpf` e `sexo` vazios e `dataNascimento`/`dataCriacao` em
  /// [dataNaoInformada]. Quem precisa desses dados (ex.: a tela de dados do
  /// administrador) deve obtê-los de outra fonte; este mapeamento serve à
  /// sessão (id, nome, e-mail, cargo e tenant).
  ///
  /// Lança [ArgumentError] se o DTO for de um aplicador.
  static AdminAccount paraAdminAccount(UsuarioDto dto) {
    final role = switch (dto.perfil) {
      PerfilDto.administrador => AdminRole.administrador,
      PerfilDto.subAdministrador => AdminRole.subAdministrador,
      PerfilDto.aplicador => throw ArgumentError.value(
        dto.perfil.valorJson,
        'dto.perfil',
        'Esperado um usuário com perfil ADMINISTRADOR ou SUB_ADMINISTRADOR.',
      ),
    };
    return AdminAccount(
      id: dto.id,
      tenantId: dto.tenantId,
      email: dto.email,
      nome: dto.nome,
      cpf: '',
      dataNascimento: dataNaoInformada,
      sexo: '',
      dataCriacao: dataNaoInformada,
      status: switch (dto.status) {
        StatusUsuarioDto.ativo => UsuarioStatus.ativo,
        StatusUsuarioDto.desativado => UsuarioStatus.desativado,
      },
      role: role,
    );
  }
}
