import '../../autenticacao/core/admin_account.dart';

/// ViewModel de [AdminAccount] para a listagem do dashboard de
/// Gerenciamento de Administradores (GEOPRAG-36).
class AdministradorViewModel {
  final String email;
  final String nome;
  final AdminRole role;
  final bool ativo;

  const AdministradorViewModel({
    required this.email,
    required this.nome,
    required this.role,
    required this.ativo,
  });

  bool get isAdministrador => role == AdminRole.administrador;

  String get cargoLabel =>
      isAdministrador ? 'Administrador' : 'Sub-Administrador';

  factory AdministradorViewModel.fromEntity(AdminAccount entity) {
    return AdministradorViewModel(
      email: entity.email,
      nome: entity.nome,
      role: entity.role,
      ativo: entity.ativo,
    );
  }
}
