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
    UsuarioStatus? status,
    DateTime? dataDesativacao,
    String? cpf,
    String? telefone,
    String? cep,
    String? rua,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? uf,
  }) {
    return Aplicador(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      status: status ?? this.status,
      dataCriacao: dataCriacao,
      dataDesativacao: dataDesativacao ?? this.dataDesativacao,
      email: email,
      cpf: cpf ?? this.cpf,
      dataNascimento: dataNascimento,
      sexo: sexo,
      telefone: telefone ?? this.telefone,
      cep: cep ?? this.cep,
      rua: rua ?? this.rua,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      uf: uf ?? this.uf,
    );
  }
}
