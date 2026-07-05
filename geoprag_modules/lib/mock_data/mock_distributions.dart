import '../models/distribution.dart';

final List<Distribution> mockDistributions = [
  Distribution(id: 'd1', productId: 'p1', quantity: 2, deliveryDate: DateTime.now().subtract(const Duration(days: 10)), responsible: 'João Silva'),
  Distribution(id: 'd2', productId: 'p2', quantity: 5, deliveryDate: DateTime.now().subtract(const Duration(days: 20)), responsible: 'Pedro Alves'),
  Distribution(id: 'd3', productId: 'p1', quantity: 1, deliveryDate: DateTime.now().subtract(const Duration(days: 2)), responsible: 'João Silva'),
  Distribution(id: 'd4', productId: 'p4', quantity: 10, deliveryDate: DateTime.now().subtract(const Duration(days: 5)), responsible: 'Ana Costa'),
  Distribution(id: 'd5', productId: 'p5', quantity: 3, deliveryDate: DateTime.now().subtract(const Duration(days: 15)), responsible: 'Carlos Lima'),
];
