/// Bairro do município. O ponto guarda o nome; o `id` é o que o servidor pede
/// ao cadastrar ou editar um ponto.
class Bairro {
  const Bairro({required this.id, required this.nome});

  final String id;
  final String nome;
}
