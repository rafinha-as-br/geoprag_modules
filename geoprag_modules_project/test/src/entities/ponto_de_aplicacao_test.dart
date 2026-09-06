import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';

PontoDeAplicacao pontoDeTeste({
  EstadoPontoDeAplicacao estado = EstadoPontoDeAplicacao.enderecada,
  String? aplicadorId,
  List<Subponto> subpontos = const [],
  double larguraMetros = 2,
  double profundidadeMetros = 0.5,
  double velocidadeMetrosPorSegundo = 0.4,
}) {
  return PontoDeAplicacao(
    id: 'pa1',
    identificador: '#GAS1',
    nome: 'Córrego Gasparinho',
    bairro: 'Gasparinho',
    endereco: 'Rua Pedro Simon',
    numeroReferencia: 'Em frente ao nº 240',
    descricaoDoTrecho: 'Trecho de 400 m.',
    larguraMetros: larguraMetros,
    profundidadeMetros: profundidadeMetros,
    velocidadeMetrosPorSegundo: velocidadeMetrosPorSegundo,
    dosagemMl: 120,
    distanciaEntreSubpontosMetros: 50,
    quantidadeDeSubpontos: 8,
    aplicadorId: aplicadorId,
    estado: estado,
    subpontos: subpontos,
  );
}

final _execucao = Subponto(
  latitude: -26.9312,
  longitude: -48.9567,
  realizadoEm: DateTime(2026, 8, 24, 8, 12),
  registradoEm: DateTime(2026, 8, 24, 18, 40),
);

void main() {
  group('vazão', () {
    test('é o produto dos três parâmetros hidrológicos brutos', () {
      final ponto = pontoDeTeste(
        larguraMetros: 2,
        profundidadeMetros: 0.5,
        velocidadeMetrosPorSegundo: 0.4,
      );

      expect(ponto.vazao, closeTo(0.4, 0.0001));
    });

    test('acompanha a alteração dos parâmetros, sem valor persistido', () {
      final ponto = pontoDeTeste().copyWith(larguraMetros: 4);

      expect(ponto.vazao, closeTo(0.8, 0.0001));
    });
  });

  group('invariantes de estado', () {
    test('ponto ativo sem aplicador é rejeitado na construção', () {
      expect(
        () => pontoDeTeste(estado: EstadoPontoDeAplicacao.ativa),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });

    test('ponto ativo com aplicador é aceito', () {
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.ativa,
        aplicadorId: '1',
      );

      expect(ponto.estado, EstadoPontoDeAplicacao.ativa);
    });

    test('desatribuir aplicador de um ponto ativo é rejeitado', () {
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.ativa,
        aplicadorId: '1',
      );

      expect(
        ponto.desatribuirAplicador,
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });

    test('desatribuir de um ponto direcionado devolve a endereçada', () {
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.direcionada,
        aplicadorId: '1',
      ).desatribuirAplicador();

      expect(ponto.aplicadorId, isNull);
      expect(ponto.estado, EstadoPontoDeAplicacao.enderecada);
    });

    test('atribuir aplicador promove endereçada a direcionada', () {
      final ponto = pontoDeTeste().atribuirAplicador('2');

      expect(ponto.aplicadorId, '2');
      expect(ponto.estado, EstadoPontoDeAplicacao.direcionada);
    });

    test('atribuir aplicador não altera o estado de um ponto inativo', () {
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.inativa,
      ).atribuirAplicador('2');

      expect(ponto.estado, EstadoPontoDeAplicacao.inativa);
    });
  });

  group('Agendamento.gerar', () {
    test('gera as datas espaçadas por intervaloDias a partir de dataInicio', () {
      final agendamento = Agendamento.gerar(
        dataInicio: DateTime(2026, 9, 10),
        intervaloDias: 15,
        quantidadeRecorrencias: 3,
      );

      expect(agendamento.datas, hasLength(3));
      expect(agendamento.datas[0].data, DateTime(2026, 9, 10));
      expect(agendamento.datas[1].data, DateTime(2026, 9, 25));
      expect(agendamento.datas[2].data, DateTime(2026, 10, 10));
    });

    test('cada data nasce pendente', () {
      final agendamento = Agendamento.gerar(
        dataInicio: DateTime(2026, 9, 10),
        intervaloDias: 15,
        quantidadeRecorrencias: 2,
      );

      expect(
        agendamento.datas.every((d) => d.status == StatusDataAgendada.pendente),
        isTrue,
      );
    });
  });

  group('ativar', () {
    final agendamento = Agendamento.gerar(
      dataInicio: DateTime(2026, 9, 10),
      intervaloDias: 15,
      quantidadeRecorrencias: 1,
    );

    test('promove direcionada a ativa e aplica o agendamento', () {
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.direcionada,
        aplicadorId: '1',
      ).ativar(agendamento);

      expect(ponto.estado, EstadoPontoDeAplicacao.ativa);
      expect(ponto.agendamento, agendamento);
    });

    test('reativa um ponto inativo com um agendamento novo', () {
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.inativa,
        aplicadorId: '1',
      ).ativar(agendamento);

      expect(ponto.estado, EstadoPontoDeAplicacao.ativa);
    });

    test('rejeita ativar um ponto endereçado (sem aplicador)', () {
      expect(
        () => pontoDeTeste().ativar(agendamento),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });

    test('rejeita ativar um ponto já ativo', () {
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.ativa,
        aplicadorId: '1',
      );

      expect(
        () => ponto.ativar(agendamento),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });

    test('não apaga o histórico de execuções já registradas', () {
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.inativa,
        aplicadorId: '1',
        subpontos: [_execucao],
      ).ativar(agendamento);

      expect(ponto.subpontos, [_execucao]);
    });
  });

  group('desativar', () {
    for (final origem in [
      EstadoPontoDeAplicacao.enderecada,
      EstadoPontoDeAplicacao.direcionada,
      EstadoPontoDeAplicacao.ativa,
      EstadoPontoDeAplicacao.inativa,
    ]) {
      test('transiciona de $origem para desativado', () {
        final ponto = pontoDeTeste(
          estado: origem,
          aplicadorId: origem == EstadoPontoDeAplicacao.enderecada
              ? null
              : '1',
        ).desativar();

        expect(ponto.estado, EstadoPontoDeAplicacao.desativado);
      });
    }

    test('rejeita desativar um ponto já desativado', () {
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.direcionada,
        aplicadorId: '1',
      ).desativar();

      expect(ponto.desativar, throwsA(isA<OperacaoNaoPermitidaException>()));
    });

    test('guarda o estado anterior para reativar depois', () {
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.ativa,
        aplicadorId: '1',
      ).desativar();

      expect(ponto.estadoAnterior, EstadoPontoDeAplicacao.ativa);
    });

    test('cancela as datas pendentes do agendamento vigente', () {
      final agendamento = Agendamento.gerar(
        dataInicio: DateTime(2026, 9, 10),
        intervaloDias: 15,
        quantidadeRecorrencias: 3,
      );
      final comUmaConcluida = agendamento.datas[0].copyWith(
        status: StatusDataAgendada.concluida,
      );
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.ativa,
        aplicadorId: '1',
      ).copyWith(
        agendamento: Agendamento(
          dataInicio: agendamento.dataInicio,
          intervaloDias: agendamento.intervaloDias,
          quantidadeRecorrencias: agendamento.quantidadeRecorrencias,
          datas: [comUmaConcluida, agendamento.datas[1], agendamento.datas[2]],
        ),
      ).desativar();

      expect(ponto.agendamento!.datas[0].status, StatusDataAgendada.concluida);
      expect(ponto.agendamento!.datas[1].status, StatusDataAgendada.cancelada);
      expect(ponto.agendamento!.datas[2].status, StatusDataAgendada.cancelada);
    });

    test('não quebra ao desativar um ponto sem nenhum agendamento', () {
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.enderecada,
      ).desativar();

      expect(ponto.agendamento, isNull);
    });
  });

  group('reativar', () {
    test('devolve o ponto ao estado em que estava antes de desativar', () {
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.direcionada,
        aplicadorId: '1',
      ).desativar().reativar();

      expect(ponto.estado, EstadoPontoDeAplicacao.direcionada);
      expect(ponto.estadoAnterior, isNull);
    });

    test('rejeita reativar um ponto que não está desativado', () {
      final ponto = pontoDeTeste(estado: EstadoPontoDeAplicacao.enderecada);

      expect(ponto.reativar, throwsA(isA<OperacaoNaoPermitidaException>()));
    });

    test(
      'rejeita reativar um ponto desativado sem estado anterior registrado',
      () {
        final ponto = pontoDeTeste(estado: EstadoPontoDeAplicacao.desativado);

        expect(ponto.reativar, throwsA(isA<OperacaoNaoPermitidaException>()));
      },
    );
  });

  group('cicloConcluido', () {
    test('falso sem nenhum agendamento', () {
      expect(pontoDeTeste().cicloConcluido, isFalse);
    });

    test('falso com alguma data ainda pendente', () {
      final ponto = pontoDeTeste().copyWith(
        agendamento: Agendamento.gerar(
          dataInicio: DateTime(2026, 9, 10),
          intervaloDias: 15,
          quantidadeRecorrencias: 2,
        ),
      );

      expect(ponto.cicloConcluido, isFalse);
    });

    test('verdadeiro quando todas as datas estão concluídas', () {
      final agendamento = Agendamento.gerar(
        dataInicio: DateTime(2026, 9, 10),
        intervaloDias: 15,
        quantidadeRecorrencias: 2,
      );
      final concluido = Agendamento(
        dataInicio: agendamento.dataInicio,
        intervaloDias: agendamento.intervaloDias,
        quantidadeRecorrencias: agendamento.quantidadeRecorrencias,
        datas: [
          for (final data in agendamento.datas)
            data.copyWith(status: StatusDataAgendada.concluida),
        ],
      );
      final ponto = pontoDeTeste().copyWith(agendamento: concluido);

      expect(ponto.cicloConcluido, isTrue);
    });
  });

  group('execuções', () {
    test('ponto ativo sem execução é sinalizado como alerta', () {
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.ativa,
        aplicadorId: '1',
      );

      expect(ponto.ativoSemRegistro, isTrue);
      expect(ponto.primeiraExecucao, isNull);
    });

    test('ponto ativo com execução registrada não vira alerta', () {
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.ativa,
        aplicadorId: '1',
        subpontos: [_execucao],
      );

      expect(ponto.ativoSemRegistro, isFalse);
      expect(ponto.primeiraExecucao, _execucao);
    });

    test('ponto endereçado sem execução não é alerta (não está em operação)', () {
      expect(pontoDeTeste().ativoSemRegistro, isFalse);
    });

    test('a lista de execuções não é modificável por fora da entidade', () {
      final ponto = pontoDeTeste(subpontos: [_execucao]);

      expect(() => ponto.subpontos.add(_execucao), throwsUnsupportedError);
    });
  });
}
