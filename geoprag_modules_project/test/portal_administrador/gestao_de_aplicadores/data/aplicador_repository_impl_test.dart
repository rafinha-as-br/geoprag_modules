import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/core/aplicador.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/data/aplicador_repository_impl.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/data/mock_aplicadores.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';

void main() {
  late AplicadorRepositoryImpl repository;
  late List<Aplicador> estadoOriginal;

  setUp(() {
    repository = AplicadorRepositoryImpl();
    estadoOriginal = List.of(mockApplicators);
  });

  tearDown(() {
    // ativar/desativar mutam a lista mock global em memória — restaura o
    // estado original para não vazar entre testes.
    for (var i = 0; i < mockApplicators.length; i++) {
      mockApplicators[i] = estadoOriginal[i];
    }
  });

  test('listar retorna todos os aplicadores mockados', () async {
    final result = await repository.listar();
    expect(result.length, mockApplicators.length);
  });

  test('buscarPorId retorna o aplicador correspondente', () async {
    final result = await repository.buscarPorId('2');
    expect(result.nome, 'Maria Souza');
  });

  test('buscarPorId lança EntidadeNaoEncontradaException quando o id não existe', () {
    expect(
      () => repository.buscarPorId('inexistente'),
      throwsA(isA<EntidadeNaoEncontradaException>()),
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

  test('ativar muda o status do aplicador para ativo', () async {
    await repository.desativar('1');
    await repository.ativar('1');
    final result = await repository.buscarPorId('1');
    expect(result.status, 'ativo');
  });

  test('desativar muda o status do aplicador para desativado', () async {
    await repository.desativar('1');
    final result = await repository.buscarPorId('1');
    expect(result.status, 'desativado');
  });

  test('ativar lança EntidadeNaoEncontradaException quando o id não existe', () {
    expect(
      () => repository.ativar('inexistente'),
      throwsA(isA<EntidadeNaoEncontradaException>()),
    );
  });

  test('desativar lança EntidadeNaoEncontradaException quando o id não existe', () {
    expect(
      () => repository.desativar('inexistente'),
      throwsA(isA<EntidadeNaoEncontradaException>()),
    );
  });
}
