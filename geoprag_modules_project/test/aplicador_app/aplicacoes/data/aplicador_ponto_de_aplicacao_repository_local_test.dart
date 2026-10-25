import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/data/aplicador_ponto_de_aplicacao_repository_local.dart';
import 'package:geoprag_modules/aplicador_app/local/local.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';

import '../../local/apoio_do_banco.dart';

void main() {
  late BancoLocal banco;
  late PontoDaoSqflite pontos;
  late AplicacaoDaoSqflite aplicacoes;

  AplicadorPontoDeAplicacaoRepositoryLocal comHoje(DateTime hoje) =>
      AplicadorPontoDeAplicacaoRepositoryLocal(
        pontos: pontos,
        aplicacoes: aplicacoes,
        agora: () => hoje,
      );

  setUp(() async {
    banco = await abrirBancoEmMemoria();
    pontos = PontoDaoSqflite(banco.db);
    aplicacoes = AplicacaoDaoSqflite(banco.db);
  });

  tearDown(() => banco.fechar());

  group('listarMeusPontos', () {
    test('devolve só os pontos do aplicador, por nome', () async {
      await pontos.salvarTodos([
        pontoDeTeste('p2', nome: 'Zeta'),
        pontoDeTeste('p1', nome: 'Alfa'),
        pontoDeTeste('p3', aplicadorId: 'outro'),
      ]);

      final lista = await comHoje(agoraDeTeste).listarMeusPontos('aplicador-1');

      expect(lista.map((p) => p.id), ['p1', 'p2']);
    });

    test('não devolve ponto desativado', () async {
      await pontos.salvarTodos([
        pontoDeTeste('p1'),
        pontoDeTeste('p2', estado: EstadoPontoDeAplicacao.desativado),
      ]);

      final lista = await comHoje(agoraDeTeste).listarMeusPontos('aplicador-1');

      expect(lista.map((p) => p.id), ['p1']);
    });

    test('devolve lista vazia quando o banco não tem nada', () async {
      expect(
        await comHoje(agoraDeTeste).listarMeusPontos('aplicador-1'),
        isEmpty,
      );
    });
  });

  group('buscarPorId', () {
    test('devolve o ponto guardado', () async {
      await pontos.salvar(pontoDeTeste('p1'));

      expect((await comHoje(agoraDeTeste).buscarPorId('p1')).id, 'p1');
    });

    test('lança EntidadeNaoEncontradaException para id inexistente', () {
      expect(
        () => comHoje(agoraDeTeste).buscarPorId('inexistente'),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );
    });
  });

  // pontoDeTeste: datas p1-d1 (25/10, pendente) e p1-d2 (concluída), tolerância
  // padrão de 4 dias, 3 subpontos por aplicação.
  group('alerta de atraso, sem rede', () {
    setUp(() => pontos.salvar(pontoDeTeste('p1')));

    test('no último dia da tolerância ainda está em dia', () async {
      final repo = comHoje(DateTime(2026, 10, 29, 23, 59));

      expect(await repo.estaEmAtraso('p1'), isFalse);
      expect(await repo.idsDePontosEmAtraso('aplicador-1'), isEmpty);
    });

    test('no dia seguinte ao fim da tolerância está em atraso', () async {
      final repo = comHoje(DateTime(2026, 10, 30));

      expect(await repo.estaEmAtraso('p1'), isTrue);
      expect(await repo.idsDePontosEmAtraso('aplicador-1'), {'p1'});
    });

    test('só lista pontos do aplicador informado', () async {
      final repo = comHoje(DateTime(2026, 10, 30));

      expect(await repo.idsDePontosEmAtraso('outro'), isEmpty);
    });

    test('respeita a tolerância do ponto, guardada no banco', () async {
      await pontos.salvar(pontoDeTeste('p1').editarTolerancia(10));

      expect(await comHoje(DateTime(2026, 10, 30)).estaEmAtraso('p1'), isFalse);
      expect(await comHoje(DateTime(2026, 11, 5)).estaEmAtraso('p1'), isTrue);
    });

    test('alerta removido no Portal (vindo do pull) não aparece', () async {
      final ponto = pontoDeTeste('p1');
      final datas = ponto.agendamento!.datas;
      await pontos.salvar(
        ponto.copyWith(
          agendamento: ponto.agendamento!.copyWith(
            datas: [
              DataAgendada(
                id: datas.first.id,
                data: datas.first.data,
                alertaRemovidoEm: DateTime.utc(2026, 10, 29, 12),
              ),
              datas.last,
            ],
          ),
        ),
      );

      expect(await comHoje(DateTime(2026, 10, 30)).estaEmAtraso('p1'), isFalse);
    });

    test('o "hoje" padrão é o de São Paulo (UTC-3), não o do aparelho', () {
      final agora = agoraNoFusoDaOperacao();

      expect(agora.isUtc, isTrue);
      expect(
        DateTime.now().toUtc().difference(agora).inMinutes,
        closeTo(180, 1),
      );
    });

    test('aplicação completa feita aqui dá baixa na data e apaga o alerta, '
        'antes de sincronizar', () async {
      final repo = comHoje(DateTime(2026, 10, 30));
      expect(await repo.estaEmAtraso('p1'), isTrue);

      await aplicacoes.gravarComOutbox(
        aplicacaoDeTeste(
          'a1',
          pontoId: 'p1',
          subpontos: [
            subpontoDeTeste('s1'),
            subpontoDeTeste('s2'),
            subpontoDeTeste('s3'),
          ],
        ),
        const [],
      );

      expect(await repo.estaEmAtraso('p1'), isFalse);
      final ponto = await repo.buscarPorId('p1');
      expect(
        ponto.agendamento!.datas.first.status,
        StatusDataAgendada.concluida,
      );
    });

    test('aplicação incompleta não dá baixa: o alerta continua', () async {
      final repo = comHoje(DateTime(2026, 10, 30));
      await aplicacoes.gravarComOutbox(
        aplicacaoDeTeste(
          'a1',
          pontoId: 'p1',
          subpontos: [subpontoDeTeste('s1')],
        ),
        const [],
      );

      expect(await repo.estaEmAtraso('p1'), isTrue);
    });

    test('lança EntidadeNaoEncontradaException para ponto inexistente', () {
      expect(
        () => comHoje(DateTime(2026, 10, 30)).estaEmAtraso('inexistente'),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );
    });
  });
}
