import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/data/denuncia_repository_impl.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/data/mock_denuncias.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';

void main() {
  late DenunciaRepositoryImpl repository;

  setUp(() {
    repository = DenunciaRepositoryImpl();
  });

  test('listar retorna todas as denúncias mockadas', () async {
    final result = await repository.listar();
    expect(result.length, mockReports.length);
  });

  test('buscarPorId retorna a denúncia correspondente', () async {
    final result = await repository.buscarPorId('r1');
    expect(result.descricao, 'Muitos borrachudos na varanda');
  });

  test('buscarPorId lança EntidadeNaoEncontradaException quando o id não existe', () {
    expect(
      () => repository.buscarPorId('inexistente'),
      throwsA(isA<EntidadeNaoEncontradaException>()),
    );
  });

  test('buscarHistorico retorna o histórico de auditoria da denúncia conhecida', () async {
    final result = await repository.buscarHistorico('r2');
    expect(result, hasLength(2));
  });

  test('buscarHistorico retorna lista vazia quando não há histórico mockado', () async {
    final result = await repository.buscarHistorico('r3');
    expect(result, isEmpty);
  });
}
