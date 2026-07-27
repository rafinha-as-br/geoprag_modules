import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/data/aplicador_repository_impl.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/data/mock_aplicadores.dart';

void main() {
  late AplicadorRepositoryImpl repository;

  setUp(() {
    repository = AplicadorRepositoryImpl();
  });

  test('listar retorna todos os aplicadores mockados', () async {
    final result = await repository.listar();
    expect(result.length, mockApplicators.length);
  });

  test('buscarPorId retorna o aplicador correspondente', () async {
    final result = await repository.buscarPorId('2');
    expect(result.nome, 'Maria Souza');
  });

  test('buscarPorId lança StateError quando o id não existe', () {
    expect(
      () => repository.buscarPorId('inexistente'),
      throwsA(isA<StateError>()),
    );
  });

  test('buscarHistorico retorna o histórico de atuações do aplicador conhecido', () async {
    final result = await repository.buscarHistorico('2');
    expect(result, hasLength(2));
  });

  test('buscarHistorico retorna lista vazia quando o aplicador não tem histórico mockado', () async {
    final result = await repository.buscarHistorico('1');
    expect(result, isEmpty);
  });
}
