import '../../../src/entities/usuario.dart';

/// Endereço de residência do Aplicador é obrigatório (RN "Dados da
/// Conta"), por isso os campos herdados de [Usuario] que compõem o
/// endereço (`cep`, `rua`, `numero`, `bairro`, `cidade`, `uf`) são
/// `required` aqui — `complemento` continua opcional (nem todo endereço
/// tem complemento).
class Aplicador extends Usuario {
  final String id;
  final String telefone;

  const Aplicador({
    required this.id,
    required super.nome,
    required super.status,
    required super.dataCriacao,
    super.dataDesativacao,
    required super.email,
    required super.cpf,
    required super.dataNascimento,
    required super.sexo,
    required super.cep,
    required super.rua,
    required super.numero,
    super.complemento,
    required super.bairro,
    required super.cidade,
    required super.uf,
    required this.telefone,
  });

  Aplicador copyWith({
    String? id,
    String? nome,
    String? bairro,
    UsuarioStatus? status,
    DateTime? dataDesativacao,
    String? cpf,
    String? telefone,
    String? endereco,
  }) {
    return Aplicador(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      bairro: bairro ?? this.bairro,
      status: status ?? this.status,
      dataCriacao: dataCriacao,
      dataDesativacao: dataDesativacao ?? this.dataDesativacao,
      email: email,
      cpf: cpf ?? this.cpf,
      dataNascimento: dataNascimento,
      sexo: sexo,
      telefone: telefone ?? this.telefone,
      endereco: endereco ?? this.endereco,
    );
  }
}
