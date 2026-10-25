import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/data/aplicador_ponto_de_aplicacao_repository_impl.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/data/admin_ponto_de_aplicacao_repository_impl.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/data/mock_pontos_de_aplicacao.dart';
import 'package:geoprag_modules/src/atraso/alerta_de_atraso_repository_impl.dart';
import 'package:geoprag_modules/src/auditoria/evento_auditoria.dart';
import 'package:geoprag_modules/src/auditoria/evento_auditoria_repository_impl.dart';
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
        pontos.any(
          (ponto) => ponto.estado == EstadoPontoDeAplicacao.desativado,
        ),
        isFalse,
      );
    });

    test(
      'devolve lista vazia quando o aplicador não tem nenhum ponto',
      () async {
        final pontos = await repository.listarMeusPontos('inexistente');

        expect(pontos, isEmpty);
      },
    );
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

    group('recorrência cumprida ao concluir a aplicação', () {
      // Ponto próprio, com 2 subpontos por aplicação e 2 recorrências, para
      // não depender dos dados do mock.
      PontoDeAplicacao pontoComCiclo() => PontoDeAplicacao(
        id: 'pa-ciclo',
        identificador: '#CIC1',
        nome: 'Córrego do ciclo',
        bairro: 'Gasparinho',
        endereco: 'Rua Pedro Simon',
        numeroReferencia: 'Em frente ao nº 240',
        descricaoDoTrecho: 'Trecho de 100 m.',
        larguraMetros: 2,
        profundidadeMetros: 0.5,
        velocidadeMetrosPorSegundo: 0.4,
        dosagemMl: 120,
        distanciaEntreSubpontosMetros: 50,
        quantidadeDeSubpontos: 2,
        aplicadorId: '1',
        estado: EstadoPontoDeAplicacao.ativa,
        agendamento: Agendamento.gerar(
          dataInicio: DateTime(2026, 10, 1),
          intervaloDias: 15,
          quantidadeRecorrencias: 2,
        ),
      );

      Subponto subponto(int minuto) => Subponto(
        id: 'sp-ciclo-$minuto',
        latitude: -26.93,
        longitude: -48.95,
        realizadoEm: DateTime(2026, 10, 2, 9, minuto),
        registradoEm: DateTime(2026, 10, 2, 9, minuto),
      );

      setUp(() => mockPontosDeAplicacao.add(pontoComCiclo()));

      test(
        'marca a data pendente mais antiga quando a aplicação é concluída',
        () async {
          await repository.registrarSubponto('pa-ciclo', subponto(0));
          var ponto = await repository.buscarPorId('pa-ciclo');
          expect(
            ponto.agendamento!.datas.map((d) => d.status),
            everyElement(StatusDataAgendada.pendente),
          );

          await repository.registrarSubponto('pa-ciclo', subponto(1));
          ponto = await repository.buscarPorId('pa-ciclo');

          expect(ponto.agendamento!.datas.map((d) => d.status), [
            StatusDataAgendada.concluida,
            StatusDataAgendada.pendente,
          ]);
          expect(
            ponto.subpontos.last.dataAgendadaId,
            ponto.agendamento!.datas.first.id,
          );
        },
      );

      test('cumprir a última data leva o ponto a inativa na leitura do '
          'portal', () async {
        for (var i = 0; i < 4; i++) {
          await repository.registrarSubponto('pa-ciclo', subponto(i));
        }
        final lidoPeloAplicador = await repository.buscarPorId('pa-ciclo');
        expect(lidoPeloAplicador.cicloConcluido, isTrue);

        final portal = AdminPontoDeAplicacaoRepositoryImpl(
          eventoAuditoriaRepository: EventoAuditoriaRepositoryImpl(),
          alertaDeAtrasoRepository: AlertaDeAtrasoRepositoryImpl(),
          autor: const AutorUsuario(
            email: 'admin@gaspar.sc.gov.br',
            perfil: 'Administrador',
          ),
        );
        final lidoPeloPortal = await portal.buscarPorId('pa-ciclo');

        expect(lidoPeloPortal.estado, EstadoPontoDeAplicacao.inativa);
      });
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

    test(
      'a data só é concluída quando a aplicação completa seus subpontos',
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
      },
    );

    test(
      'registrar sem agendamento vigente só acrescenta o subponto',
      () async {
        await repository.registrarSubponto('pa2', subpontoDe(1));

        final ponto = await repository.buscarPorId('pa2');
        expect(ponto.agendamento, isNull);
        expect(ponto.subpontos.map((s) => s.id), ['sp-baixa-1']);
      },
    );
  });

  group('atraso calculado localmente (GEOPRAG-161)', () {
    // Ponto próprio: 2 subpontos por aplicação e 2 recorrências (01/10 e
    // 16/10), tolerância padrão de 4 dias — último dia em dia: 05/10.
    PontoDeAplicacao pontoComCiclo() => PontoDeAplicacao(
      id: 'pa-atraso',
      identificador: '#ATR1',
      nome: 'Córrego do atraso',
      bairro: 'Gasparinho',
      endereco: 'Rua Pedro Simon',
      numeroReferencia: 'Em frente ao nº 240',
      descricaoDoTrecho: 'Trecho de 100 m.',
      larguraMetros: 2,
      profundidadeMetros: 0.5,
      velocidadeMetrosPorSegundo: 0.4,
      dosagemMl: 120,
      distanciaEntreSubpontosMetros: 50,
      quantidadeDeSubpontos: 2,
      aplicadorId: 'aplicador-atraso',
      estado: EstadoPontoDeAplicacao.ativa,
      agendamento: Agendamento.gerar(
        dataInicio: DateTime(2026, 10, 1),
        intervaloDias: 15,
        quantidadeRecorrencias: 2,
      ),
    );

    Subponto subponto(int minuto) => Subponto(
      id: 'sp-atraso-$minuto',
      latitude: -26.93,
      longitude: -48.95,
      realizadoEm: DateTime(2026, 10, 6, 9, minuto),
      registradoEm: DateTime(2026, 10, 6, 9, minuto),
    );

    AplicadorPontoDeAplicacaoRepositoryImpl comHoje(
      DateTime hoje, {
      AlertaDeAtrasoRepositoryImpl? alertas,
    }) => AplicadorPontoDeAplicacaoRepositoryImpl(
      alertaDeAtrasoRepository: alertas,
      agora: () => hoje,
    );

    setUp(() => mockPontosDeAplicacao.add(pontoComCiclo()));
    tearDown(mockAlertasDeAtrasoRemovidos.clear);

    test('no último dia da tolerância ainda está em dia', () async {
      final repo = comHoje(DateTime(2026, 10, 5, 23, 59));

      expect(await repo.estaEmAtraso('pa-atraso'), isFalse);
      expect(
        await repo.idsDePontosEmAtraso('aplicador-atraso'),
        isNot(contains('pa-atraso')),
      );
    });

    test('no dia seguinte ao fim da tolerância está em atraso', () async {
      final repo = comHoje(DateTime(2026, 10, 6));

      expect(await repo.estaEmAtraso('pa-atraso'), isTrue);
      expect(await repo.idsDePontosEmAtraso('aplicador-atraso'), {'pa-atraso'});
    });

    test('só lista pontos do aplicador informado', () async {
      final repo = comHoje(DateTime(2026, 10, 6));

      expect(
        await repo.idsDePontosEmAtraso('outro-aplicador'),
        isNot(contains('pa-atraso')),
      );
    });

    test(
      'concluir a aplicação faz o alerta sumir na hora, sem sincronizar',
      () async {
        final repo = comHoje(DateTime(2026, 10, 6));
        expect(await repo.estaEmAtraso('pa-atraso'), isTrue);

        await repo.registrarSubponto('pa-atraso', subponto(0));
        expect(await repo.estaEmAtraso('pa-atraso'), isTrue);

        await repo.registrarSubponto('pa-atraso', subponto(1));

        expect(await repo.estaEmAtraso('pa-atraso'), isFalse);
        expect(
          await repo.idsDePontosEmAtraso('aplicador-atraso'),
          isNot(contains('pa-atraso')),
        );
      },
    );

    test(
      'o registro da aplicação continua possível em ponto em atraso',
      () async {
        final repo = comHoje(DateTime(2026, 10, 6));
        expect(await repo.estaEmAtraso('pa-atraso'), isTrue);

        await repo.registrarSubponto('pa-atraso', subponto(0));

        expect((await repo.buscarPorId('pa-atraso')).subpontos, hasLength(1));
      },
    );

    test('remoção manual feita no Portal some no App; a próxima recorrência '
        'atrasada volta a alertar', () async {
      final alertas = AlertaDeAtrasoRepositoryImpl();
      final repo = comHoje(DateTime(2026, 10, 6), alertas: alertas);
      final ponto = await repo.buscarPorId('pa-atraso');

      await alertas.remover(
        pontoId: 'pa-atraso',
        dataAgendadaId: ponto.agendamento!.datas.first.id,
      );
      expect(await repo.estaEmAtraso('pa-atraso'), isFalse);

      // Cumprida a 1ª recorrência, a seguinte (16/10) passa a ser a vigente;
      // passada a tolerância dela (16/10 + 4 dias), o alerta volta.
      await repo.registrarSubponto('pa-atraso', subponto(0));
      await repo.registrarSubponto('pa-atraso', subponto(1));
      final depois = comHoje(DateTime(2026, 10, 21), alertas: alertas);
      expect(await depois.estaEmAtraso('pa-atraso'), isTrue);
    });

    test('lança EntidadeNaoEncontradaException para ponto inexistente', () {
      expect(
        () => comHoje(DateTime(2026, 10, 6)).estaEmAtraso('inexistente'),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );
    });
  });
}
