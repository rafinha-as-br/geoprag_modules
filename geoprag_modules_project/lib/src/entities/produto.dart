/// Produto biológico que o aplicador escolhe ao registrar uma aplicação. Quem
/// o define é o servidor (o pull entrega a lista); o app só o guarda.
class Produto {
  const Produto({required this.id, required this.nome});

  final String id;
  final String nome;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Produto && other.id == id && other.nome == nome);

  @override
  int get hashCode => Object.hash(id, nome);
}
