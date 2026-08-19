import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/inventory/data/insumo_repository_impl.dart';
import 'package:geoprag_modules/aplicador_app/inventory/data/mock_insumos.dart';

void main() {
  test('listar retorna todos os insumos mockados', () async {
    final repository = InsumoRepositoryImpl();

    final result = await repository.listar();

    expect(result.length, mockInsumos.length);
    expect(result.first.nome, mockInsumos.first.nome);
  });
}
