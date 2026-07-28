class Applicator {
  final String id;
  final String name;
  final String neighborhood;
  final String status; // 'ativo' | 'desativado'
  final DateTime registeredAt;

  const Applicator({
    required this.id,
    required this.name,
    required this.neighborhood,
    required this.status,
    required this.registeredAt,
  });
}
