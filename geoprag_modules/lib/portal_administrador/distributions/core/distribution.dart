class Distribution {
  final String id;
  final String productId;
  final int quantity;
  final DateTime deliveryDate;
  final String responsible;

  const Distribution({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.deliveryDate,
    required this.responsible,
  });
}
