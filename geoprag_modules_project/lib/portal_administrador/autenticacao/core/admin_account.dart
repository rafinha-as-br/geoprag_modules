import '../../../src/entities/usuario.dart';

enum AdminRole { administrador, subAdministrador }

class AdminAccount extends Usuario {
  final AdminRole role;

  const AdminAccount({
    required super.email,
    required super.nome,
    required this.role,
  });
}
