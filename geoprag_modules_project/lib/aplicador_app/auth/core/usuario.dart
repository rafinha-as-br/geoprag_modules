/// Usuário autenticado no App Aplicador (sessão).
///
/// [id] e [tenantId] vêm do servidor (login e `GET /auth/me`) e nunca são
/// digitados nem alterados no aparelho (GEOPRAG-186). [cpf] é opcional: o
/// contrato da API devolve só `id`, `nome`, `perfil`, `tenantId`, `email` e
/// `status`, então ele só existe quando o app conhece o valor (ex.: o CPF
/// digitado no login).
class Usuario {
  final String id;
  final String nome;
  final String? cpf;
  final String tenantId;

  const Usuario({
    required this.id,
    required this.nome,
    this.cpf,
    required this.tenantId,
  });
}
