/// Usuário base do sistema GeoPrag, comum aos três perfis (Aplicador,
/// Administrador e Sub-Administrador).
///
/// Contém apenas os dados cadastrais confirmados como comuns aos três
/// perfis na regra de negócio (ver "Regra de Negócio - Dados Cadastrais de
/// Usuários"): `email` e `nome`. Demais campos levantados na regra (CPF,
/// data de nascimento, sexo, CEP) são específicos por perfil ou ainda "a
/// confirmar" — não entram aqui.
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

  const Usuario({required this.email, required this.nome});
}
