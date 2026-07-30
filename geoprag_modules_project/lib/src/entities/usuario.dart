/// Usuário base do sistema GeoPrag, comum aos três perfis (Aplicador,
/// Administrador e Sub-Administrador).
///
/// Contém os dados cadastrais obrigatórios para os três perfis, conforme
/// "Regra de Negócio - Dados da Conta" (filha de "Regra de Negócio -
/// Regras de Conta"): `email`, `nome`, `cpf`, `dataNascimento` e `sexo`.
/// `CEP` não entra aqui — é obrigatório apenas para o Aplicador, não para
/// os três perfis.
///
/// `senha` não é modelada como campo desta entidade: é tratada só como
/// parâmetro de criação/autenticação nos repositories, nunca armazenada em
/// um objeto de domínio (evita reter senha em objetos de sessão de vida
/// longa, como `AdminAccount`).
///
/// Cada módulo estende esta entidade com seus campos específicos (ex.:
/// `AdminAccount`, em `autenticacao/core/admin_account.dart`, adiciona
/// `role`).
abstract class Usuario {
  final String email;
  final String nome;
  final String cpf;
  final DateTime dataNascimento;
  final String sexo;

  const Usuario({
    required this.email,
    required this.nome,
    required this.cpf,
    required this.dataNascimento,
    required this.sexo,
  });
}
