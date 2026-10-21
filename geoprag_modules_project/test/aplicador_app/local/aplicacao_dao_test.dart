import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/local/local.dart';

import 'apoio_do_banco.dart';

void main() {
  late BancoLocal banco;
  late AplicacaoDaoSqflite dao;
  late OutboxDaoSqflite outbox;

  setUp(() async {
    banco = await abrirBancoEmMemoria();
    dao = AplicacaoDaoSqflite(banco.db);
    outbox = OutboxDaoSqflite(banco.db);
  });

  tearDown(() => banco.fechar());

  Future<int> contar(String tabela) async {
    final linhas = await banco.db.rawQuery('SELECT COUNT(*) AS n FROM $tabela');
    return linhas.single['n']! as int;
  }

  group('gravarComOutbox', () {
    test('grava a aplicação, os subpontos e os itens da outbox', () async {
      final aplicacao = aplicacaoDeTeste(
        'app-1',
        subpontos: [subpontoDeTeste('s-1'), subpontoDeTeste('s-2')],
      );

      await dao.gravarComOutbox(aplicacao, [
        for (final s in aplicacao.subpontos) itemDoSubponto(aplicacao, s),
      ]);

      expect(await contar('aplicacoes'), 1);
      expect(await contar('subpontos'), 2);
      expect(await contar('outbox'), 2);
      final item = await outbox.buscarPorId('s-1');
      expect(item?.estado, EstadoDoItemDaOutbox.pendente);
      expect(item?.pontoId, 'ponto-1');
    });

    test(
      'é atômica: item repetido na outbox desfaz a aplicação inteira',
      () async {
        final primeira = aplicacaoDeTeste(
          'app-1',
          subpontos: [subpontoDeTeste('s-1')],
        );
        await dao.gravarComOutbox(primeira, [
          itemDoSubponto(primeira, primeira.subpontos.single),
        ]);

        // Outra aplicação cujo item repete o `id` já enfileirado.
        final segunda = aplicacaoDeTeste(
          'app-2',
          subpontos: [subpontoDeTeste('s-1'), subpontoDeTeste('s-9')],
        );
        await expectLater(
          dao.gravarComOutbox(segunda, [
            itemDoSubponto(segunda, subpontoDeTeste('s-9')),
            itemDoSubponto(segunda, subpontoDeTeste('s-1')),
          ]),
          throwsA(anything),
        );

        expect(await dao.buscarPorId('app-2'), isNull);
        expect(await contar('aplicacoes'), 1);
        expect(await contar('subpontos'), 1);
        expect(await contar('outbox'), 1);
        expect(await outbox.buscarPorId('s-9'), isNull);
      },
    );

    test('é append-only: acrescentar um subponto grava só o novo', () async {
      final um = aplicacaoDeTeste('app-1', subpontos: [subpontoDeTeste('s-1')]);
      await dao.gravarComOutbox(um, [itemDoSubponto(um, um.subpontos.single)]);

      final dois = um.comSubponto(
        subpontoDeTeste(
          's-2',
          realizadoEm: agoraDeTeste.add(const Duration(minutes: 5)),
        ),
      );
      await dao.gravarComOutbox(dois, [
        itemDoSubponto(dois, dois.subpontos.last),
      ]);

      expect(await contar('aplicacoes'), 1);
      expect(await contar('subpontos'), 2);
      expect(await contar('outbox'), 2);
      final lida = await dao.buscarPorId('app-1');
      expect([for (final s in lida!.subpontos) s.id], ['s-1', 's-2']);
    });

    test('aceita aplicação ainda sem subpontos', () async {
      await dao.gravarComOutbox(aplicacaoDeTeste('app-1'), const []);

      expect((await dao.buscarPorId('app-1'))?.subpontos, isEmpty);
    });
  });

  group('leitura', () {
    test(
      'devolve a aplicação com os mesmos dados e instantes gravados',
      () async {
        final aplicacao = aplicacaoDeTeste(
          'app-1',
          subpontos: [
            subpontoDeTeste('s-1', latitude: -26.95, longitude: -48.95),
          ],
        );
        await dao.gravarComOutbox(aplicacao, [
          itemDoSubponto(aplicacao, aplicacao.subpontos.single),
        ]);

        final lida = (await dao.buscarPorId('app-1'))!;

        expect(lida.id, 'app-1');
        expect(lida.pontoId, 'ponto-1');
        expect(lida.aplicadorId, 'aplicador-1');
        expect(lida.dataAgendadaId, 'ponto-1-d1');
        expect(lida.produtoId, 'produto-1');
        expect(
          lida.realizadoEm.isAtSameMomentAs(aplicacao.realizadoEm),
          isTrue,
        );
        expect(lida.localizacao, aplicacao.localizacao);
        final subponto = lida.subpontos.single;
        expect(subponto.latitude, -26.95);
        expect(subponto.longitude, -48.95);
        expect(
          subponto.realizadoEm.isAtSameMomentAs(
            aplicacao.subpontos.single.realizadoEm,
          ),
          isTrue,
        );
      },
    );

    test('buscarPorId devolve null para id desconhecido', () async {
      expect(await dao.buscarPorId('nao-existe'), isNull);
    });

    test(
      'listarPorPonto devolve só as do ponto, da mais antiga à mais recente',
      () async {
        for (final (id, ponto) in [
          ('a', 'ponto-1'),
          ('b', 'ponto-2'),
          ('c', 'ponto-1'),
        ]) {
          await dao.gravarComOutbox(
            aplicacaoDeTeste(id, pontoId: ponto),
            const [],
          );
        }

        final lidas = await dao.listarPorPonto('ponto-1');

        expect([for (final a in lidas) a.id], ['a', 'c']);
      },
    );

    test('subpontos saem na ordem em que foram realizados', () async {
      final aplicacao = aplicacaoDeTeste(
        'app-1',
        subpontos: [
          subpontoDeTeste(
            'tarde',
            realizadoEm: agoraDeTeste.add(const Duration(hours: 1)),
          ),
          subpontoDeTeste('cedo'),
        ],
      );
      await dao.gravarComOutbox(aplicacao, const []);

      final lida = (await dao.buscarPorId('app-1'))!;

      expect([for (final s in lida.subpontos) s.id], ['cedo', 'tarde']);
    });
  });
}
