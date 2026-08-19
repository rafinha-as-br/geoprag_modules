import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/data/mock_pontos_de_aplicacao.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/data/ponto_de_aplicacao_repository_impl.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';

void main() {
  late AdminPontoDeAplicacaoRepositoryImpl repository;

  setUp(() {
    repository = AdminPontoDeAplicacaoRepositoryImpl();
  });

  test('listar retorna todos os pontos mockados', () async {
    final result = await repository.listar();
    expect(result.length, mockPontosDeAplicacao.length);
  });

  test('buscarPorId retorna o ponto correspondente', () async {
    final result = await repository.buscarPorId('2');
    expect(result.bairro, 'Poço Grande');
  });

  test('buscarPorId lança EntidadeNaoEncontradaException quando o id não existe', () {
    expect(
      () => repository.buscarPorId('inexistente'),
      throwsA(isA<EntidadeNaoEncontradaException>()),
    );
  });

  test('criar adiciona um ponto planejado, sem exigir aplicador', () async {
    final quantidadeAntes = mockPontosDeAplicacao.length;

    final ponto = await repository.criar(
      bairro: 'Novo Bairro',
      lat: -26.99,
      lng: -48.95,
    );

    expect(ponto.status, StatusPontoDeAplicacao.planejada);
    expect(ponto.aplicadorId, isNull);
    expect(mockPontosDeAplicacao.length, quantidadeAntes + 1);

    mockPontosDeAplicacao.removeWhere((p) => p.id == ponto.id);
  });

  test('atribuirAplicador atualiza o aplicadorId do ponto', () async {
    final atualizado = await repository.atribuirAplicador('4', '2');

    expect(atualizado.aplicadorId, '2');

    await repository.atribuirAplicador('4', null);
  });

  test('atribuirAplicador lança EntidadeNaoEncontradaException para id inexistente', () {
    expect(
      () => repository.atribuirAplicador('inexistente', '1'),
      throwsA(isA<EntidadeNaoEncontradaException>()),
    );
  });

  test('desativar marca o ponto como inativo (desativação lógica)', () async {
    final ponto = await repository.criar(
      bairro: 'Bairro Temporário',
      lat: -26.98,
      lng: -48.94,
    );

    final desativado = await repository.desativar(ponto.id);

    expect(desativado.ativo, isFalse);

    mockPontosDeAplicacao.removeWhere((p) => p.id == ponto.id);
  });

  test('desativar lança EntidadeNaoEncontradaException para id inexistente', () {
    expect(
      () => repository.desativar('inexistente'),
      throwsA(isA<EntidadeNaoEncontradaException>()),
    );
  });

  test('editar atualiza bairro, latitude e longitude do ponto', () async {
    final atualizado = await repository.editar(
      '4',
      bairro: 'Bairro Editado',
      lat: -27.0,
      lng: -49.0,
    );

    expect(atualizado.bairro, 'Bairro Editado');
    expect(atualizado.lat, -27.0);
    expect(atualizado.lng, -49.0);

    await repository.editar('4', bairro: 'Santa Terezinha', lat: -26.9950, lng: -48.9390);
  });

  test('editar lança EntidadeNaoEncontradaException para id inexistente', () {
    expect(
      () => repository.editar('inexistente', bairro: 'X', lat: 0, lng: 0),
      throwsA(isA<EntidadeNaoEncontradaException>()),
    );
  });
}
