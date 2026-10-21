import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/local/local.dart';

import 'apoio_do_banco.dart';

void main() {
  late BancoLocal banco;
  late AplicacaoDaoSqflite aplicacoes;
  late OutboxDaoSqflite dao;
  var relogio = DateTime.utc(2026, 10, 20, 16);

  setUp(() async {
    banco = await abrirBancoEmMemoria();
    aplicacoes = AplicacaoDaoSqflite(banco.db);
    relogio = DateTime.utc(2026, 10, 20, 16);
    dao = OutboxDaoSqflite(banco.db, agora: () => relogio);
  });

  tearDown(() => banco.fechar());

  /// Enfileira um subponto de [pontoId] criado [minutos] depois da base.
  Future<void> enfileira(
    String id, {
    String pontoId = 'ponto-1',
    int minutos = 0,
  }) async {
    final subponto = subpontoDeTeste(id);
    final aplicacao = aplicacaoDeTeste(
      'app-$id',
      pontoId: pontoId,
      subpontos: [subponto],
    );
    await aplicacoes.gravarComOutbox(aplicacao, [
      itemDoSubponto(
        aplicacao,
        subponto,
        criadoEm: agoraDeTeste.add(Duration(minutes: minutos)),
      ),
    ]);
  }

  test('item novo entra PENDENTE, sem tentativas nem erro', () async {
    await enfileira('s-1');

    final item = (await dao.buscarPorId('s-1'))!;

    expect(item.estado, EstadoDoItemDaOutbox.pendente);
    expect(item.tentativas, 0);
    expect(item.ultimoErro, isNull);
    expect(item.ultimaTentativaEm, isNull);
    expect(item.tipo, TipoDoItemDaOutbox.subponto);
  });

  group('pendentes', () {
    test('devolve do mais antigo para o mais recente', () async {
      await enfileira('tarde', minutos: 10);
      await enfileira('cedo', minutos: 1);
      await enfileira('meio', minutos: 5);

      final ids = [for (final i in await dao.pendentes()) i.id];

      expect(ids, ['cedo', 'meio', 'tarde']);
    });

    test('limite corta o lote', () async {
      for (var i = 0; i < 5; i++) {
        await enfileira('s-$i', minutos: i);
      }

      expect(await dao.pendentes(limite: 3), hasLength(3));
    });

    test('não devolve itens que já saíram da fila', () async {
      await enfileira('s-1');
      await enfileira('s-2', minutos: 1);
      await dao.marcarEnviando(['s-1']);

      expect([for (final i in await dao.pendentes()) i.id], ['s-2']);
    });
  });

  group('ciclo de envio', () {
    test('marcarEnviando soma uma tentativa e guarda o instante', () async {
      await enfileira('s-1');

      await dao.marcarEnviando(['s-1']);

      final item = (await dao.buscarPorId('s-1'))!;
      expect(item.estado, EstadoDoItemDaOutbox.enviando);
      expect(item.tentativas, 1);
      expect(item.ultimaTentativaEm?.isAtSameMomentAs(relogio), isTrue);
    });

    test('marcarEnviando ignora item que não está PENDENTE', () async {
      await enfileira('s-1');
      await dao.marcarEnviando(['s-1']);

      await dao.marcarEnviando(['s-1']);

      expect((await dao.buscarPorId('s-1'))!.tentativas, 1);
    });

    test('marcarEnviado conclui e limpa o último erro', () async {
      await enfileira('s-1');
      await dao.marcarEnviando(['s-1']);
      await dao.registrarFalha('s-1', 'sem conexão');
      await dao.marcarEnviando(['s-1']);

      await dao.marcarEnviado(['s-1']);

      final item = (await dao.buscarPorId('s-1'))!;
      expect(item.estado, EstadoDoItemDaOutbox.enviado);
      expect(item.ultimoErro, isNull);
      expect(item.tentativas, 2);
    });

    test('marcarRejeitado guarda o motivo e não volta à fila', () async {
      await enfileira('s-1');
      await dao.marcarEnviando(['s-1']);

      await dao.marcarRejeitado('s-1', 'Ponto inexistente.');

      final item = (await dao.buscarPorId('s-1'))!;
      expect(item.estado, EstadoDoItemDaOutbox.rejeitado);
      expect(item.ultimoErro, 'Ponto inexistente.');
      expect(await dao.pendentes(), isEmpty);
    });

    test(
      'registrarFalha devolve o item à fila sem perder o registro',
      () async {
        await enfileira('s-1');
        await dao.marcarEnviando(['s-1']);

        await dao.registrarFalha('s-1', 'Tempo esgotado.');

        final item = (await dao.buscarPorId('s-1'))!;
        expect(item.estado, EstadoDoItemDaOutbox.pendente);
        expect(item.ultimoErro, 'Tempo esgotado.');
        expect(item.tentativas, 1);
        expect([for (final i in await dao.pendentes()) i.id], ['s-1']);
      },
    );

    test('registrarFalha não mexe em item que não estava ENVIANDO', () async {
      await enfileira('s-1');
      await dao.marcarEnviando(['s-1']);
      await dao.marcarEnviado(['s-1']);

      await dao.registrarFalha('s-1', 'tarde demais');

      expect(
        (await dao.buscarPorId('s-1'))!.estado,
        EstadoDoItemDaOutbox.enviado,
      );
    });

    test('lote sem ids não faz nada', () async {
      await expectLater(dao.marcarEnviando(const []), completes);
      await expectLater(dao.marcarEnviado(const []), completes);
    });

    test('o payload gravado não muda ao longo do ciclo', () async {
      await enfileira('s-1');
      final antes = (await dao.buscarPorId('s-1'))!.payload;

      await dao.marcarEnviando(['s-1']);
      await dao.registrarFalha('s-1', 'sem rede');

      expect((await dao.buscarPorId('s-1'))!.payload, antes);
    });
  });

  test('reenfileirarEmAndamento devolve os ENVIANDO e conta quantos', () async {
    await enfileira('s-1');
    await enfileira('s-2', minutos: 1);
    await enfileira('s-3', minutos: 2);
    await dao.marcarEnviando(['s-1', 's-2']);
    await dao.marcarEnviado(['s-2']);

    final voltaram = await dao.reenfileirarEmAndamento();

    expect(voltaram, 1);
    expect([for (final i in await dao.pendentes()) i.id], ['s-1', 's-3']);
    expect(
      (await dao.buscarPorId('s-2'))!.estado,
      EstadoDoItemDaOutbox.enviado,
    );
  });

  test('contarPorEstado agrupa a fila', () async {
    await enfileira('s-1');
    await enfileira('s-2', minutos: 1);
    await enfileira('s-3', minutos: 2);
    await dao.marcarEnviando(['s-1']);
    await dao.marcarRejeitado('s-3', 'motivo');

    expect(await dao.contarPorEstado(), {
      EstadoDoItemDaOutbox.enviando: 1,
      EstadoDoItemDaOutbox.pendente: 1,
      EstadoDoItemDaOutbox.rejeitado: 1,
    });
  });

  group('pontoIdsComPendencias', () {
    test('inclui pontos com item PENDENTE ou ENVIANDO', () async {
      await enfileira('s-1', pontoId: 'ponto-1');
      await enfileira('s-2', pontoId: 'ponto-2', minutos: 1);
      await dao.marcarEnviando(['s-2']);

      expect(await dao.pontoIdsComPendencias(), {'ponto-1', 'ponto-2'});
    });

    test('exclui pontos cujos itens já foram enviados ou rejeitados', () async {
      await enfileira('s-1', pontoId: 'ponto-1');
      await enfileira('s-2', pontoId: 'ponto-2', minutos: 1);
      await dao.marcarEnviando(['s-1']);
      await dao.marcarEnviado(['s-1']);
      await dao.marcarRejeitado('s-2', 'motivo');

      expect(await dao.pontoIdsComPendencias(), isEmpty);
    });
  });
}
