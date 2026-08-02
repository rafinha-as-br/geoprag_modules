class Aplicador {
  final String id;
  final String nome;
  final String bairro;
  final String status; // 'ativo' | 'desativado'
  final DateTime dataCadastro;
  final String cpf;
  final String telefone;
  final String endereco;

  const Aplicador({
    required this.id,
    required this.nome,
    required this.bairro,
    required this.status,
    required this.dataCadastro,
    required this.cpf,
    required this.telefone,
    required this.endereco,
  });

  Aplicador copyWith({
    String? id,
    String? nome,
    String? bairro,
    String? status,
    DateTime? dataCadastro,
    String? cpf,
    String? telefone,
    String? endereco,
  }) {
    return Aplicador(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      bairro: bairro ?? this.bairro,
      status: status ?? this.status,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      cpf: cpf ?? this.cpf,
      telefone: telefone ?? this.telefone,
      endereco: endereco ?? this.endereco,
    );
  }
}
