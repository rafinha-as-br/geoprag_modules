class Product {
  final String id;
  final String name;
  final String batch;
  final DateTime expirationDate;
  final String status;
  final int quantity;

  const Product({
    required this.id,
    required this.name,
    required this.batch,
    required this.expirationDate,
    required this.status,
    required this.quantity,
  });
}
