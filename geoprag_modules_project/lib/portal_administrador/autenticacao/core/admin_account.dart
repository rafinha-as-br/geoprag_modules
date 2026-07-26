enum AdminRole { administrador, subAdministrador }

class AdminAccount {
  final String email;
  final String nome;
  final AdminRole role;

  const AdminAccount({
    required this.email,
    required this.nome,
    required this.role,
  });
}
