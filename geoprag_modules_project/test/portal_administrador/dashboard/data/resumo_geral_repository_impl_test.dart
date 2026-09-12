import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/dashboard/data/mock_resumo_geral.dart';
import 'package:geoprag_modules/portal_administrador/dashboard/data/resumo_geral_repository_impl.dart';

void main() {
  test('buscar retorna o resumo geral mockado', () async {
    final repository = ResumoGeralRepositoryImpl();

    final result = await repository.buscar();

    expect(result, mockResumoGeral);
  });
}
