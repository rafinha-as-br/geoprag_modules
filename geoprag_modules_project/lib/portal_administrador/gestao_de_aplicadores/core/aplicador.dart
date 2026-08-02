import '../../../src/entities/usuario.dart';

class Aplicador extends Usuario {
  final String id;
  final String bairro;
  final String telefone;
  final String endereco;

  const Aplicador({
    required this.id,
    required super.nome,
    required this.bairro,
    required super.status,
    required super.dataCriacao,
    super.dataDesativacao,
    required super.email,
    required super.cpf,
    required super.dataNascimento,
    required super.sexo,
    required this.telefone,
    required this.endereco,
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
