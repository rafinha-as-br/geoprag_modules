import '../core/product.dart';

final List<Product> mockProducts = [
  Product(
    id: 'p1',
    name: 'BTI Líquido',
    batch: 'L-001',
    expirationDate: DateTime.now().add(const Duration(days: 30)),
    status: 'Produto em estoque',
    quantity: 50,
  ),
  Product(
    id: 'p2',
    name: 'BTI Granulado',
    batch: 'L-002',
    expirationDate: DateTime.now().add(const Duration(days: 60)),
    status: 'Produto distribuído',
    quantity: 10,
  ),
  Product(
    id: 'p3',
    name: 'BTI Líquido',
    batch: 'L-003',
    expirationDate: DateTime.now().subtract(const Duration(days: 5)),
    status: 'Produto encerrado',
    quantity: 0,
  ),
  Product(
    id: 'p4',
    name: 'BTI Granulado',
    batch: 'L-004',
    expirationDate: DateTime.now().add(const Duration(days: 90)),
    status: 'Produto comprado',
    quantity: 100,
  ),
  Product(
    id: 'p5',
    name: 'BTI Líquido',
    batch: 'L-005',
    expirationDate: DateTime.now().add(const Duration(days: 120)),
    status: 'Produto em estoque',
    quantity: 200,
  ),
];
