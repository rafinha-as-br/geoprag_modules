import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/entities/atraso_de_aplicacao.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';

import '../../portal_administrador/gestao_de_aplicacoes/gestao_de_aplicacoes_fixtures.dart';

void main() {
  final agendamento = Agendamento.gerar(
    dataInicio: DateTime(2026, 10, 1),
    intervaloDias: 7,
    quantidadeRecorrencias: 3,
  );
  PontoDeAplicacao ativo({int toleranciaDias = 4}) => pontoDeAplicacao(
    estado: EstadoPontoDeAplicacao.ativa,
    aplicadorId: '1',
    agendamento: agendamento,
    toleranciaDias: toleranciaDias,
  );

  group('estadoDeAtraso', () {
    test('passou da tolerância da data pendente mais antiga: em atraso', () {
      expect(
        ativo().estadoDeAtraso(dataDeReferencia: DateTime(2026, 10, 6)),
        EstadoDeAtraso.emAtraso,
      );
    });

    test('dentro da tolerância do ponto: em dia', () {
      expect(
        ativo().estadoDeAtraso(dataDeReferencia: DateTime(2026, 10, 5)),
        EstadoDeAtraso.emDia,
      );
      expect(
        ativo(
          toleranciaDias: 10,
        ).estadoDeAtraso(dataDeReferencia: DateTime(2026, 10, 6)),
        EstadoDeAtraso.emDia,
      );
    });

    test('alerta removido da recorrência atual: em dia', () {
      expect(
        ativo().estadoDeAtraso(
          dataDeReferencia: DateTime(2026, 10, 6),
          alertasRemovidos: {'2026-10-01-0'},
        ),
        EstadoDeAtraso.emDia,
      );
    });

    test('remoção de outra recorrência não vale para a atual', () {
      expect(
        ativo().estadoDeAtraso(
          dataDeReferencia: DateTime(2026, 10, 6),
          alertasRemovidos: {'2026-10-01-1'},
        ),
        EstadoDeAtraso.emAtraso,
      );
    });

    test('recorrência concluída deixa de alertar e a seguinte vale', () {
      final cumprida = agendamento.copyWith(
        datas: [
          agendamento.datas[0].copyWith(status: StatusDataAgendada.concluida),
          ...agendamento.datas.skip(1),
        ],
      );
      final ponto = pontoDeAplicacao(
        estado: EstadoPontoDeAplicacao.ativa,
        aplicadorId: '1',
        agendamento: cumprida,
      );

      expect(
        ponto.estadoDeAtraso(dataDeReferencia: DateTime(2026, 10, 10)),
        EstadoDeAtraso.emDia,
      );
      expect(
        ponto.estadoDeAtraso(dataDeReferencia: DateTime(2026, 10, 13)),
        EstadoDeAtraso.emAtraso,
      );
    });

    test('ponto fora de operação ou sem agendamento nunca está em atraso', () {
      final dataTardia = DateTime(2027, 1, 1);
      expect(
        pontoDeAplicacao(
          estado: EstadoPontoDeAplicacao.ativa,
          aplicadorId: '1',
        ).estadoDeAtraso(dataDeReferencia: dataTardia),
        EstadoDeAtraso.emDia,
      );
      expect(
        pontoDeAplicacao(
          estado: EstadoPontoDeAplicacao.inativa,
          aplicadorId: '1',
          agendamento: agendamento,
        ).estadoDeAtraso(dataDeReferencia: dataTardia),
        EstadoDeAtraso.emDia,
      );
    });
  });
}
