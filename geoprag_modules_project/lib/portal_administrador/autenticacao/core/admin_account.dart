import '../../../src/entities/usuario.dart';

enum AdminRole { administrador, subAdministrador }

/// Rótulo de exibição do cargo — reaproveitado pelo dropdown de conta do
/// side menu (GEOPRAG-146) e por `AdministradorViewModel.cargoLabel`, que
/// antes duplicava esta mesma checagem.
extension AdminRoleLabel on AdminRole {
  String get label =>
      this == AdminRole.administrador ? 'Administrador' : 'Sub-Administrador';
}

class AdminAccount extends Usuario {
  final AdminRole role;

  const AdminAccount({
    required super.email,
    required super.nome,
    required super.cpf,
    required super.dataNascimento,
    required super.sexo,
    super.cep,
    required super.dataCriacao,
    super.status = UsuarioStatus.ativo,
    super.dataDesativacao,
    required this.role,
  });

  AdminAccount copyWith({
    String? email,
    String? nome,
    AdminRole? role,
    UsuarioStatus? status,
    DateTime? dataDesativacao,
  }) => AdminAccount(
    email: email ?? this.email,
    nome: nome ?? this.nome,
    cpf: cpf,
    dataNascimento: dataNascimento,
    sexo: sexo,
    cep: cep,
    dataCriacao: dataCriacao,
    role: role ?? this.role,
    status: status ?? this.status,
    dataDesativacao: dataDesativacao ?? this.dataDesativacao,
  );
}
