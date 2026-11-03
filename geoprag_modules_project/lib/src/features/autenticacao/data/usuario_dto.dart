import 'json_helpers.dart';

/// Perfil do usuário, como o servidor o devolve (`ADMINISTRADOR`,
/// `SUB_ADMINISTRADOR` ou `APLICADOR`).
enum PerfilDto {
  administrador('ADMINISTRADOR'),
  subAdministrador('SUB_ADMINISTRADOR'),
  aplicador('APLICADOR');

  const PerfilDto(this.valorJson);

  /// Valor textual do contrato da API.
  final String valorJson;

  static PerfilDto fromJson(String valor) {
    for (final perfil in values) {
      if (perfil.valorJson == valor) return perfil;
    }
    throw FormatException('Perfil desconhecido na resposta: "$valor".');
  }
}

/// Estado do acesso do usuário, como o servidor o devolve.
enum StatusUsuarioDto {
  ativo('ATIVO'),
  desativado('DESATIVADO');

  const StatusUsuarioDto(this.valorJson);

  final String valorJson;

  static StatusUsuarioDto fromJson(String valor) {
    for (final status in values) {
      if (status.valorJson == valor) return status;
    }
    throw FormatException('Status desconhecido na resposta: "$valor".');
  }
}

/// `usuario` do login e de `GET /auth/me` (contrato v0, "API - Autenticação").
///
/// DTO de transporte: vive na camada de API e nunca vaza para o domínio;
/// a conversão para as entidades de sessão fica em `auth_mappers.dart`.
class UsuarioDto {
  const UsuarioDto({
    required this.id,
    required this.nome,
    required this.perfil,
    required this.tenantId,
    required this.email,
    required this.status,
  });

  final String id;
  final String nome;
  final PerfilDto perfil;

  /// Tenant do usuário; vem do servidor (do token), nunca de digitação.
  final String tenantId;
  final String email;
  final StatusUsuarioDto status;

  factory UsuarioDto.fromJson(Map<String, dynamic> json) => UsuarioDto(
    id: textoObrigatorio(json, 'id'),
    nome: textoObrigatorio(json, 'nome'),
    perfil: PerfilDto.fromJson(textoObrigatorio(json, 'perfil')),
    tenantId: textoObrigatorio(json, 'tenantId'),
    email: textoObrigatorio(json, 'email'),
    status: StatusUsuarioDto.fromJson(textoObrigatorio(json, 'status')),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'perfil': perfil.valorJson,
    'tenantId': tenantId,
    'email': email,
    'status': status.valorJson,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsuarioDto &&
          other.id == id &&
          other.nome == nome &&
          other.perfil == perfil &&
          other.tenantId == tenantId &&
          other.email == email &&
          other.status == status);

  @override
  int get hashCode => Object.hash(id, nome, perfil, tenantId, email, status);

  @override
  String toString() => 'UsuarioDto(id: $id, perfil: ${perfil.valorJson})';
}
