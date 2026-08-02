import '../../../src/entities/usuario.dart';
import '../../autenticacao/core/admin_account.dart';

/// ViewModel de [AdminAccount] — usado tanto na listagem quanto no dialog
/// de detalhes do dashboard de Gerenciamento de Administradores
/// (GEOPRAG-36). Carrega todos os dados cadastrais, não só o resumo
/// exibido na tabela.
class AdministradorViewModel {
  final String email;
  final String nome;
  final String cpf;
  final DateTime dataNascimento;
  final String sexo;
  final AdminRole role;
  final UsuarioStatus status;
  final DateTime dataCriacao;
  final DateTime? dataDesativacao;

  const AdministradorViewModel({
    required this.email,
    required this.nome,
    required this.cpf,
    required this.dataNascimento,
    required this.sexo,
    required this.role,
    required this.status,
    required this.dataCriacao,
    this.dataDesativacao,
  });

  bool get ativo => status == UsuarioStatus.ativo;

  bool get isAdministrador => role == AdminRole.administrador;

  String get cargoLabel =>
      isAdministrador ? 'Administrador' : 'Sub-Administrador';

  factory AdministradorViewModel.fromEntity(AdminAccount entity) {
    return AdministradorViewModel(
      email: entity.email,
      nome: entity.nome,
      cpf: entity.cpf,
      dataNascimento: entity.dataNascimento,
      sexo: entity.sexo,
      role: entity.role,
      status: entity.status,
      dataCriacao: entity.dataCriacao,
      dataDesativacao: entity.dataDesativacao,
    );
  }
}
