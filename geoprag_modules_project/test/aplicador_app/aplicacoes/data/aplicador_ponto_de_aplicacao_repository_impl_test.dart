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
          id: 'sp-teste-2',
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
            id: 'sp-teste-4',
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
            id: 'sp-teste-6',
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

  group('registrarSubponto dá baixa na data agendada (GEOPRAG-188)', () {
    // pa2 é #BEL1: ativa, aplicador '2', 5 subpontos por aplicação.
    Subponto subpontoDe(int n) => Subponto(
      id: 'sp-baixa-$n',
      latitude: 0,
      longitude: 0,
      realizadoEm: DateTime(2026, 10, 12, 10, n),
      registradoEm: DateTime(2026, 10, 12, 10, n),
    );

    void agendarPa2(List<StatusDataAgendada> status) {
      final index = mockPontosDeAplicacao.indexWhere((p) => p.id == 'pa2');
      mockPontosDeAplicacao[index] = mockPontosDeAplicacao[index].copyWith(
        agendamento: Agendamento(
          dataInicio: DateTime(2026, 10, 5),
          intervaloDias: 7,
          quantidadeRecorrencias: status.length,
          datas: [
            for (var i = 0; i < status.length; i++)
              DataAgendada(
                id: 'd-$i',
                data: DateTime(2026, 10, 5).add(Duration(days: 7 * i)),
                status: status[i],
              ),
          ],
        ),
      );
    }

    List<StatusDataAgendada> statusPa2() => mockPontosDeAplicacao
        .firstWhere((p) => p.id == 'pa2')
        .agendamento!
        .datas
        .map((d) => d.status)
        .toList();

    test('a data só é concluída quando a aplicação completa seus subpontos',
        () async {
      agendarPa2([StatusDataAgendada.pendente, StatusDataAgendada.pendente]);

      for (var n = 1; n <= 4; n++) {
        await repository.registrarSubponto('pa2', subpontoDe(n));
      }
      expect(statusPa2(), [
        StatusDataAgendada.pendente,
        StatusDataAgendada.pendente,
      ]);

      await repository.registrarSubponto('pa2', subpontoDe(5));

      expect(statusPa2(), [
        StatusDataAgendada.concluida,
        StatusDataAgendada.pendente,
      ]);
    });

    test('registrar sem agendamento vigente só acrescenta o subponto', () async {
      await repository.registrarSubponto('pa2', subpontoDe(1));

      final ponto = await repository.buscarPorId('pa2');
      expect(ponto.agendamento, isNull);
      expect(ponto.subpontos.map((s) => s.id), ['sp-baixa-1']);
    });
  });
}
