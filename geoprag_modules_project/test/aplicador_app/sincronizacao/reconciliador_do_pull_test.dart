import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/local/local.dart';
import 'package:geoprag_modules/aplicador_app/sincronizacao/sincronizacao.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';

import '../local/apoio_do_banco.dart';
import 'apoio_da_sincronizacao.dart';
import 'apoio_do_pull.dart';

void main() {
  late BancoLocal banco;
  late PontoDaoSqflite pontos;
  late AplicacaoDaoSqflite aplicacoes;
  late OutboxDaoSqflite outbox;
  late ReconciliadorDoPull reconciliador;

  setUp(() async {
    banco = await abrirBancoEmMemoria();
    pontos = PontoDaoSqflite(banco.db);
    aplicacoes = AplicacaoDaoSqflite(banco.db);
    outbox = OutboxDaoSqflite(banco.db);
    reconciliador = reconciliadorDe(banco);
  });

  tearDown(() => banco.fechar());

  Future<List<String>> idsNoAparelho() async => [
    for (final p in await pontos.listar()) p.id,
  ];

  StatusDataAgendada? statusDaD1(PontoDeAplicacao ponto) => ponto
      .agendamento!
      .datas
      .firstWhere((d) => d.id == '${ponto.id}-d1')
      .status;

  /// Aplicação completa (3 subpontos) do ponto, com os itens na outbox.
  Future<void> registraAplicacaoCompleta(String pontoId) async {
    final subpontos = [
      for (var i = 1; i <= 3; i++) subpontoDeTeste('$pontoId-s$i'),
    ];
    final aplicacao = aplicacaoDeTeste(
      'app-$pontoId',
      pontoId: pontoId,
      subpontos: subpontos,
    );
    await aplicacoes.gravarComOutbox(aplicacao, [
      for (final s in subpontos) itemDoSubponto(aplicacao, s),
    ]);
  }

  test('insere os pontos novos e atualiza os que já existem', () async {
    await pontos.salvar(pontoDeTeste('ponto-1', nome: 'Nome antigo'));

    final resultado = await reconciliador.reconciliar(
      respostaDoPull([
        pontoDoPull('ponto-1', nome: 'Nome novo'),
        pontoDoPull('ponto-2'),
      ]),
    );

    expect(resultado.pontosSalvos, ['ponto-1', 'ponto-2']);
    expect(await idsNoAparelho(), unorderedEquals(['ponto-1', 'ponto-2']));
    expect((await pontos.buscarPorId('ponto-1'))!.nome, 'Nome novo');
  });

  test('traz os subpontos que o servidor já registrou', () async {
    await reconciliador.reconciliar(
      respostaDoPull([
        pontoDoPull('ponto-1', subpontos: [subpontoDoPull('srv-1')]),
      ]),
    );

    final ponto = (await pontos.buscarPorId('ponto-1'))!;
    expect([for (final s in ponto.subpontos) s.id], ['srv-1']);
  });

  test('ponto que saiu da resposta e não tem pendência é removido', () async {
    await pontos.salvar(pontoDeTeste('ponto-1'));
    await pontos.salvar(pontoDeTeste('ponto-2'));

    final resultado = await reconciliador.reconciliar(
      respostaDoPull([pontoDoPull('ponto-2')]),
    );

    expect(resultado.pontosRemovidos, ['ponto-1']);
    expect(await idsNoAparelho(), ['ponto-2']);
  });

  test(
    'ponto reatribuído com registro pendente continua no aparelho',
    () async {
      await pontos.salvar(pontoDeTeste('ponto-1'));
      await enfileira(aplicacoes, 's-1', pontoId: 'ponto-1');

      final resultado = await reconciliador.reconciliar(respostaDoPull([]));

      expect(resultado.pontosMantidos, ['ponto-1']);
      expect(resultado.pontosRemovidos, isEmpty);
      expect(await idsNoAparelho(), ['ponto-1']);
    },
  );

  test('ponto com registro ENVIANDO também não é apagado', () async {
    await pontos.salvar(pontoDeTeste('ponto-1'));
    await enfileira(aplicacoes, 's-1', pontoId: 'ponto-1');
    await outbox.marcarEnviando(['s-1']);

    await reconciliador.reconciliar(respostaDoPull([]));

    expect(await idsNoAparelho(), ['ponto-1']);
  });

  test(
    'depois que os pendentes são enviados, o pull seguinte remove o ponto',
    () async {
      await pontos.salvar(pontoDeTeste('ponto-1'));
      await enfileira(aplicacoes, 's-1', pontoId: 'ponto-1');
      await reconciliador.reconciliar(respostaDoPull([]));
      await outbox.marcarEnviando(['s-1']);
      await outbox.marcarEnviado(['s-1']);

      final resultado = await reconciliador.reconciliar(respostaDoPull([]));

      expect(resultado.pontosRemovidos, ['ponto-1']);
      expect(await idsNoAparelho(), isEmpty);
    },
  );

  test(
    'a aplicação e a outbox do aparelho não são tocadas pelo pull',
    () async {
      await pontos.salvar(pontoDeTeste('ponto-1'));
      await enfileira(aplicacoes, 's-1', pontoId: 'ponto-1');

      await reconciliador.reconciliar(respostaDoPull([]));
      await outbox.marcarEnviando(['s-1']);
      await outbox.marcarEnviado(['s-1']);
      await reconciliador.reconciliar(respostaDoPull([]));

      expect(await aplicacoes.buscarPorId('app-s-1'), isNotNull);
      expect(
        (await outbox.buscarPorId('s-1'))!.estado,
        EstadoDoItemDaOutbox.enviado,
      );
    },
  );

  group('baixa das aplicações locais ainda não enviadas', () {
    test(
      'a data atendida por uma aplicação completa pendente fica concluída',
      () async {
        await pontos.salvar(pontoDeTeste('ponto-1'));
        await registraAplicacaoCompleta('ponto-1');

        await reconciliador.reconciliar(
          respostaDoPull([pontoDoPull('ponto-1')]),
        );

        expect(
          statusDaD1((await pontos.buscarPorId('ponto-1'))!),
          StatusDataAgendada.concluida,
        );
      },
    );

    test(
      'depois de enviada, vale o que o servidor diz (data pendente)',
      () async {
        await pontos.salvar(pontoDeTeste('ponto-1'));
        await registraAplicacaoCompleta('ponto-1');
        await outbox.marcarEnviando(['ponto-1-s1', 'ponto-1-s2', 'ponto-1-s3']);
        await outbox.marcarEnviado(['ponto-1-s1', 'ponto-1-s2', 'ponto-1-s3']);

        await reconciliador.reconciliar(
          respostaDoPull([pontoDoPull('ponto-1')]),
        );

        expect(
          statusDaD1((await pontos.buscarPorId('ponto-1'))!),
          StatusDataAgendada.pendente,
        );
      },
    );

    test('aplicação incompleta (1 de 3 subpontos) não dá baixa', () async {
      await pontos.salvar(pontoDeTeste('ponto-1'));
      await enfileira(aplicacoes, 's-1', pontoId: 'ponto-1');

      await reconciliador.reconciliar(respostaDoPull([pontoDoPull('ponto-1')]));

      expect(
        statusDaD1((await pontos.buscarPorId('ponto-1'))!),
        StatusDataAgendada.pendente,
      );
    });

    test('data que o servidor já cancelou continua cancelada', () async {
      await pontos.salvar(pontoDeTeste('ponto-1'));
      await registraAplicacaoCompleta('ponto-1');

      await reconciliador.reconciliar(
        respostaDoPull([pontoDoPull('ponto-1', statusDaD1: 'CANCELADA')]),
      );

      expect(
        statusDaD1((await pontos.buscarPorId('ponto-1'))!),
        StatusDataAgendada.cancelada,
      );
    });
  });

  test('um ponto ilegível é ignorado e o resto da resposta segue', () async {
    await pontos.salvar(pontoDeTeste('ponto-ruim', nome: 'Como estava'));

    final resultado = await reconciliador.reconciliar(
      respostaDoPull([
        pontoDoPull('ponto-ruim', estado: 'ESTADO_NOVO'),
        pontoDoPull('ponto-bom'),
      ]),
    );

    expect(resultado.pontosIgnorados, ['ponto-ruim']);
    expect(resultado.pontosSalvos, ['ponto-bom']);
    // O ponto ilegível fica como estava: não é salvo nem tratado como retirado.
    expect((await pontos.buscarPorId('ponto-ruim'))!.nome, 'Como estava');
    expect(await idsNoAparelho(), containsAll(['ponto-ruim', 'ponto-bom']));
  });

  test('devolve os produtos e o cursor do servidor', () async {
    final resultado = await reconciliador.reconciliar(
      respostaDoPull([], cursor: '2026-10-21T10:00:00Z'),
    );

    expect([for (final p in resultado.produtos) p.id], ['produto-1']);
    expect(resultado.cursor, DateTime.utc(2026, 10, 21, 10));
  });

  test('guarda os produtos do pull e soma os do pull seguinte', () async {
    final produtos = ProdutoDaoSqflite(banco.db);

    await reconciliador.reconciliar(respostaDoPull([]));
    expect([for (final p in await produtos.listar()) p.id], ['produto-1']);

    await reconciliador.reconciliar(
      respostaDoPull(
        [],
        produtos: [
          {'id': 'produto-2', 'nome': 'Outro'},
        ],
      ),
      incremental: true,
    );
    expect([for (final p in await produtos.listar()) p.id], [
      'produto-1',
      'produto-2',
    ]);
  });

  test('guarda a tolerância e a remoção do alerta que o pull traz', () async {
    final ponto = pontoDoPull('ponto-1')..['toleranciaAtrasoDias'] = 7;
    ((ponto['agendamento'] as Map)['datas'] as List).first['alertaRemovidoEm'] =
        '2026-10-28T14:30:00Z';

    await reconciliador.reconciliar(respostaDoPull([ponto]));
    final lido = (await pontos.buscarPorId('ponto-1'))!;

    expect(lido.toleranciaDias, 7);
    expect(
      lido.agendamento!.datas.first.alertaRemovidoEm!.isAtSameMomentAs(
        DateTime.utc(2026, 10, 28, 14, 30),
      ),
      isTrue,
    );
  });
}
