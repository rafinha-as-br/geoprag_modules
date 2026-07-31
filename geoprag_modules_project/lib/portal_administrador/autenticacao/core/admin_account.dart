import '../../../src/entities/usuario.dart';

enum AdminRole { administrador, subAdministrador }

class AdminAccount extends Usuario {
  final AdminRole role;

  /// Estado do cadastro (GEOPRAG-36) — cadastro de Administrador/
  /// Sub-Administrador nunca é excluído, apenas desativado (ver RN
  /// "Cadastro e Acesso do Administrador e Sub-Administrador", seção 4,
  /// regra 4).
  final bool ativo;

  const AdminAccount({
    required super.email,
    required super.nome,
    required super.cpf,
    required super.dataNascimento,
    required super.sexo,
    required this.role,
    this.ativo = true,
  });

  AdminAccount copyWith({AdminRole? role, bool? ativo}) => AdminAccount(
    email: email,
    nome: nome,
    cpf: cpf,
    dataNascimento: dataNascimento,
    sexo: sexo,
    role: role ?? this.role,
    ativo: ativo ?? this.ativo,
  );
}
