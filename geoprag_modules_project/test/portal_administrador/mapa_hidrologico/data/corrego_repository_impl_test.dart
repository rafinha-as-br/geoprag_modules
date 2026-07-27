import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/data/corrego_repository_impl.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/data/mock_bairros.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/data/mock_corregos.dart';

void main() {
  late CorregoRepositoryImpl repository;

  setUp(() {
    repository = CorregoRepositoryImpl();
  });

  test('listar retorna todos os córregos mockados', () async {
    final result = await repository.listar();
    expect(result.length, mockStreams.length);
  });

  test('buscarPorId retorna o córrego correspondente', () async {
    final result = await repository.buscarPorId('s1');
    expect(result.nome, 'Córrego Belchior');
  });

  test('buscarPorId lança StateError quando o id não existe', () {
    expect(
      () => repository.buscarPorId('inexistente'),
      throwsA(isA<StateError>()),
    );
  });

  test('listarBairros retorna todos os bairros mockados', () async {
    final result = await repository.listarBairros();
    expect(result.length, mockBairros.length);
  });

  test('buscarBairroPorId retorna o bairro correspondente', () async {
    final result = await repository.buscarBairroPorId('b1');
    expect(result.nome, 'Belchior');
  });

  test('buscarBairroPorId lança StateError quando o id não existe', () {
    expect(
      () => repository.buscarBairroPorId('inexistente'),
      throwsA(isA<StateError>()),
    );
  });

  test('listarCorregosDoBairro retorna apenas os córregos vinculados ao bairro', () async {
    final result = await repository.listarCorregosDoBairro('b1');

    expect(result, hasLength(1));
    expect(result.first.id, 's1');
  });

  test('listarCorregosDoBairro propaga o erro se o bairro não existir', () {
    expect(
      () => repository.listarCorregosDoBairro('inexistente'),
      throwsA(isA<StateError>()),
    );
  });
}
