/// Estado do cadastro de um [Usuario] — nenhum perfil (Aplicador,
/// Administrador, Sub-Administrador) é excluído, apenas desativado.
enum UsuarioStatus { ativo, desativado }

/// Usuário base do sistema GeoPrag, comum aos três perfis (Aplicador,
/// Administrador e Sub-Administrador).
///
/// Contém os dados cadastrais obrigatórios para os três perfis, conforme
/// "Regra de Negócio - Dados da Conta" (filha de "Regra de Negócio -
/// Regras de Conta"): `email`, `nome`, `cpf`, `dataNascimento` e `sexo`.
/// `CEP` não entra aqui — é obrigatório apenas para o Aplicador, não para
/// os três perfis.
///
/// Também carrega o estado do cadastro em nível de conta — comum aos três
/// perfis, já que nenhum deles pode ser excluído, apenas desativado (ver
/// "Regra de Negócio - Cadastro e Acesso do Administrador e
/// Sub-Administrador", seção 4, regra 4, e o equivalente para o
/// Aplicador): `dataCriacao`, `status` e `dataDesativacao` (a data da
/// última desativação registrada — não é limpa ao reativar, então não
/// reflete necessariamente "ainda desativado", apenas "quando foi a
/// última vez que foi desativado"; `status` é a fonte de verdade do
/// estado atual).
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
  final DateTime dataCriacao;
  final UsuarioStatus status;
  final DateTime? dataDesativacao;

  const Usuario({
    required this.email,
    required this.nome,
    required this.cpf,
    required this.dataNascimento,
    required this.sexo,
    required this.dataCriacao,
    required this.status,
    this.dataDesativacao,
  });

  bool get ativo => status == UsuarioStatus.ativo;
}
