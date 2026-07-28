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
}
