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
}
