/// Usuário base do sistema GeoPrag, comum aos três perfis (Aplicador,
/// Administrador e Sub-Administrador).
///
/// Contém os dados cadastrais obrigatórios para os três perfis, conforme
/// "Regra de Negócio - Dados da Conta" (filha de "Regra de Negócio -
/// Regras de Conta"): `email`, `senha` (sempre um hash, nunca texto puro),
/// `nome`, `cpf`, `dataNascimento` e `sexo`. `CEP` não entra aqui — é
/// obrigatório apenas para o Aplicador, não para os três perfis.
///
/// Cada módulo estende esta entidade com seus campos específicos (ex.:
/// `AdminAccount`, em `autenticacao/core/admin_account.dart`, adiciona
/// `role`).
abstract class Usuario {
  final String email;
  final String senha;
  final String nome;
  final String cpf;
  final DateTime dataNascimento;
  final String sexo;

  const Usuario({
    required this.email,
    required this.senha,
    required this.nome,
    required this.cpf,
    required this.dataNascimento,
    required this.sexo,
  });
}
