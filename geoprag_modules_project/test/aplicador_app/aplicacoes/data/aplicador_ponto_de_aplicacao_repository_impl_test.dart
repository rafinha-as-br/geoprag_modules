import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/data/aplicador_ponto_de_aplicacao_repository_impl.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/data/mock_pontos_de_aplicacao.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';

void main() {
  late AplicadorPontoDeAplicacaoRepositoryImpl repository;
  late List<PontoDeAplicacao> original;

  setUp(() {
    repository = AplicadorPontoDeAplicacaoRepositoryImpl();
    original = List.of(mockPontosDeAplicacao);
  });

  // A fonte mockada é compartilhada com o portal administrador (mesma lista
  // global) — sem isso, um `registrarSubponto` vazaria para os demais
  // testes do pacote.
  tearDown(() {
    mockPontosDeAplicacao
      ..clear()
      ..addAll(original);
  });

  group('listarMeusPontos', () {
    test('devolve só os pontos atribuídos ao aplicadorId informado', () async {
      final pontos = await repository.listarMeusPontos('1');

      expect(pontos, isNotEmpty);
      expect(pontos.every((ponto) => ponto.aplicadorId == '1'), isTrue);
    });

    test('nunca devolve um ponto desativado', () async {
      final pontos = await repository.listarMeusPontos('1');

      expect(
        pontos.any((ponto) => ponto.estado == EstadoPontoDeAplicacao.desativado),
        isFalse,
      );
    });

    test('devolve lista vazia quando o aplicador não tem nenhum ponto', () async {
      final pontos = await repository.listarMeusPontos('inexistente');

      expect(pontos, isEmpty);
    });
  });

  group('buscarPorId', () {
    test('devolve o ponto correspondente', () async {
      final ponto = await repository.buscarPorId('pa1');

      expect(ponto.id, 'pa1');
    });

    test('lança EntidadeNaoEncontradaException quando o id não existe', () {
      expect(
        () => repository.buscarPorId('inexistente'),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );
    });
  });

  group('registrarSubponto', () {
    test('soma um subponto ao histórico de um ponto ativo', () async {
      final antes = await repository.buscarPorId('pa1');
      final totalAntes = antes.subpontos.length;
      final agora = DateTime(2026, 9, 6, 10);

      await repository.registrarSubponto(
        'pa1',
        Subponto(
          latitude: -26.93,
          longitude: -48.95,
          realizadoEm: agora,
          registradoEm: agora,
        ),
      );

      final depois = await repository.buscarPorId('pa1');
      expect(depois.subpontos.length, totalAntes + 1);
      expect(depois.subpontos.last.realizadoEm, agora);
    });

    test('rejeita registrar em um ponto que não está ativo', () async {
      // pa3 é #POO1, direcionada (ver mock_pontos_de_aplicacao.dart).
      final agora = DateTime(2026, 9, 6, 10);

      expect(
        () => repository.registrarSubponto(
          'pa3',
          Subponto(
            latitude: 0,
            longitude: 0,
            realizadoEm: agora,
            registradoEm: agora,
          ),
        ),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });

    test('lança EntidadeNaoEncontradaException quando o id não existe', () {
      final agora = DateTime(2026, 9, 6, 10);

      expect(
        () => repository.registrarSubponto(
          'inexistente',
          Subponto(
            latitude: 0,
            longitude: 0,
            realizadoEm: agora,
            registradoEm: agora,
          ),
        ),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );
    });
  });
}
