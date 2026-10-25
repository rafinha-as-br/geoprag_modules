import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';

final _inicio = DateTime(2026, 10, 1);

/// Ponto ativo com 2 subpontos por aplicação e 3 recorrências de 15 em 15
/// dias (1/10, 16/10 e 31/10), por padrão.
PontoDeAplicacao _pontoAtivo({
  Agendamento? agendamento,
  bool semAgendamento = false,
}) {
  return PontoDeAplicacao(
    id: 'pa-teste',
    identificador: '#TST1',
    nome: 'Córrego de teste',
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
    agendamento: semAgendamento
        ? null
        : agendamento ??
              Agendamento.gerar(
                dataInicio: _inicio,
                intervaloDias: 15,
                quantidadeRecorrencias: 3,
              ),
  );
}

Subponto _subponto([int minuto = 0]) => Subponto(
  id: 'sp-$minuto',
  latitude: -26.93,
  longitude: -48.95,
  realizadoEm: DateTime(2026, 10, 2, 9, minuto),
  registradoEm: DateTime(2026, 10, 2, 9, minuto),
);

PontoDeAplicacao _registrar(PontoDeAplicacao ponto, int quantidade) {
  var atual = ponto;
  for (var i = 0; i < quantidade; i++) {
    atual = atual.registrarSubponto(_subponto(i));
  }
  return atual;
}

List<StatusDataAgendada> _status(PontoDeAplicacao ponto) => [
  for (final data in ponto.agendamento!.datas) data.status,
];

void main() {
  group('DataAgendada', () {
    test('Agendamento.gerar dá a cada data um id único', () {
      final ids = [for (final d in _pontoAtivo().agendamento!.datas) d.id];

      expect(ids.toSet().length, 3);
    });

    test('o id não muda quando a data é editada ou concluída', () {
      final data = _pontoAtivo().agendamento!.datas.first;

      final editada = data.copyWith(data: DateTime(2026, 10, 9));
      final concluida = data.copyWith(status: StatusDataAgendada.concluida);

      expect(editada.id, data.id);
      expect(concluida.id, data.id);
    });
  });

  group('Agendamento.proximaDataPendente', () {
    test('é a data pendente mais antiga', () {
      final agendamento = _pontoAtivo().agendamento!;

      expect(agendamento.proximaDataPendente, agendamento.datas.first);
    });

    test('compara pelo dia, não pela posição, quando uma data foi editada', () {
      final base = _pontoAtivo().agendamento!;
      final editada = Agendamento(
        dataInicio: base.dataInicio,
        intervaloDias: base.intervaloDias,
        quantidadeRecorrencias: base.quantidadeRecorrencias,
        datas: [
          base.datas[0].copyWith(data: DateTime(2026, 11, 20)),
          base.datas[1],
          base.datas[2],
        ],
      );

      expect(editada.proximaDataPendente, base.datas[1]);
    });

    test('ignora datas concluídas e canceladas', () {
      final base = _pontoAtivo().agendamento!;
      final agendamento = Agendamento(
        dataInicio: base.dataInicio,
        intervaloDias: base.intervaloDias,
        quantidadeRecorrencias: base.quantidadeRecorrencias,
        datas: [
          base.datas[0].copyWith(status: StatusDataAgendada.concluida),
          base.datas[1].copyWith(status: StatusDataAgendada.cancelada),
          base.datas[2],
        ],
      );

      expect(agendamento.proximaDataPendente, base.datas[2]);
    });

    test('é nula quando não há data pendente', () {
      final base = _pontoAtivo().agendamento!;
      final agendamento = Agendamento(
        dataInicio: base.dataInicio,
        intervaloDias: base.intervaloDias,
        quantidadeRecorrencias: base.quantidadeRecorrencias,
        datas: [
          for (final d in base.datas)
            d.copyWith(status: StatusDataAgendada.concluida),
        ],
      );

      expect(agendamento.proximaDataPendente, isNull);
    });
  });

  group('registrarSubponto', () {
    test('um subponto que não conclui a aplicação não marca nenhuma data', () {
      final ponto = _registrar(_pontoAtivo(), 1);

      expect(ponto.subpontos, hasLength(1));
      expect(ponto.subpontos.single.dataAgendadaId, isNull);
      expect(_status(ponto), everyElement(StatusDataAgendada.pendente));
    });

    test('o subponto que conclui a aplicação marca exatamente uma data: a mais '
        'antiga pendente', () {
      final original = _pontoAtivo();
      final ponto = _registrar(original, 2);

      expect(_status(ponto), [
        StatusDataAgendada.concluida,
        StatusDataAgendada.pendente,
        StatusDataAgendada.pendente,
      ]);
      expect(
        ponto.subpontos.last.dataAgendadaId,
        original.agendamento!.datas.first.id,
      );
    });

    test('guarda o vínculo só no concluinte e não altera os subpontos '
        'anteriores', () {
      final umSubponto = _registrar(_pontoAtivo(), 1);
      final anterior = umSubponto.subpontos.first;

      final ponto = umSubponto.registrarSubponto(_subponto(1));

      expect(ponto.subpontos.first, same(anterior));
      expect(ponto.subpontos.first.dataAgendadaId, isNull);
      expect(ponto.subpontos.last.dataAgendadaId, isNotNull);
    });

    test('duas aplicações seguidas marcam duas datas, em ordem', () {
      final original = _pontoAtivo();
      final ponto = _registrar(original, 4);
      final datas = original.agendamento!.datas;

      expect(_status(ponto), [
        StatusDataAgendada.concluida,
        StatusDataAgendada.concluida,
        StatusDataAgendada.pendente,
      ]);
      expect(ponto.subpontos[1].dataAgendadaId, datas[0].id);
      expect(ponto.subpontos[3].dataAgendadaId, datas[1].id);
    });

    test('cumpre a data mais antiga pendente mesmo com datas editadas', () {
      final base = _pontoAtivo().agendamento!;
      final ponto = _pontoAtivo(
        agendamento: Agendamento(
          dataInicio: base.dataInicio,
          intervaloDias: base.intervaloDias,
          quantidadeRecorrencias: base.quantidadeRecorrencias,
          datas: [
            base.datas[0].copyWith(data: DateTime(2026, 11, 20)),
            base.datas[1],
            base.datas[2],
          ],
        ),
      );

      final resultado = _registrar(ponto, 2);

      expect(_status(resultado), [
        StatusDataAgendada.pendente,
        StatusDataAgendada.concluida,
        StatusDataAgendada.pendente,
      ]);
    });

    test('ponto sem agendamento só acrescenta o subponto, sem falhar', () {
      final ponto = _registrar(_pontoAtivo(semAgendamento: true), 2);

      expect(ponto.subpontos, hasLength(2));
      expect(ponto.agendamento, isNull);
      expect(ponto.subpontos.last.dataAgendadaId, isNull);
    });

    test('sem data pendente não marca nada e não falha', () {
      final base = _pontoAtivo().agendamento!;
      final ponto = _pontoAtivo(
        agendamento: Agendamento(
          dataInicio: base.dataInicio,
          intervaloDias: base.intervaloDias,
          quantidadeRecorrencias: base.quantidadeRecorrencias,
          datas: [
            base.datas[0].copyWith(status: StatusDataAgendada.concluida),
            base.datas[1].copyWith(status: StatusDataAgendada.cancelada),
            base.datas[2].copyWith(status: StatusDataAgendada.cancelada),
          ],
        ),
      );

      final resultado = _registrar(ponto, 2);

      expect(resultado.subpontos, hasLength(2));
      expect(resultado.subpontos.last.dataAgendadaId, isNull);
      expect(_status(resultado), _status(ponto));
    });

    test('só um ponto ativo aceita registro', () {
      final desativado = _pontoAtivo().desativar();

      expect(
        () => desativado.registrarSubponto(_subponto()),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });

    test('não altera o ponto original', () {
      final original = _pontoAtivo();

      _registrar(original, 2);

      expect(original.subpontos, isEmpty);
      expect(_status(original), everyElement(StatusDataAgendada.pendente));
    });

    test('cumprir a última data torna o ciclo concluído', () {
      final ponto = _registrar(_pontoAtivo(), 6);

      expect(_status(ponto), everyElement(StatusDataAgendada.concluida));
      expect(ponto.cicloConcluido, isTrue);
    });

    test('enquanto restar uma data pendente o ciclo não está concluído', () {
      final ponto = _registrar(_pontoAtivo(), 4);

      expect(ponto.cicloConcluido, isFalse);
    });
  });
}
