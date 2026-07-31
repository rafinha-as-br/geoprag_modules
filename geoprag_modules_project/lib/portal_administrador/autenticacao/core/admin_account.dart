import '../../../src/entities/usuario.dart';

enum AdminRole { administrador, subAdministrador }

class AdminAccount extends Usuario {
  final AdminRole role;

  const AdminAccount({
    required super.email,
    required super.nome,
    required super.cpf,
    required super.dataNascimento,
    required super.sexo,
    required super.dataCriacao,
    super.status = UsuarioStatus.ativo,
    super.dataDesativacao,
    required this.role,
  });

  AdminAccount copyWith({
    AdminRole? role,
    UsuarioStatus? status,
    DateTime? dataDesativacao,
  }) => AdminAccount(
    email: email,
    nome: nome,
    cpf: cpf,
    dataNascimento: dataNascimento,
    sexo: sexo,
    dataCriacao: dataCriacao,
    role: role ?? this.role,
    status: status ?? this.status,
    dataDesativacao: dataDesativacao ?? this.dataDesativacao,
  );
}
