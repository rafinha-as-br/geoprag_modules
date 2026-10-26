import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/local/local.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';

import 'apoio_do_banco.dart';

void main() {
  late BancoLocal banco;
  late PontoDaoSqflite dao;

  setUp(() async {
    banco = await abrirBancoEmMemoria();
    dao = PontoDaoSqflite(banco.db);
  });

  tearDown(() => banco.fechar());

  test('salva e lê o ponto com agendamento, datas e subpontos', () async {
    final original = pontoDeTeste(
      'ponto-1',
      subpontos: [
        subpontoDeTeste('s-1'),
        subpontoDeTeste(
          's-2',
          realizadoEm: agoraDeTeste.add(const Duration(days: 1)),
        ),
      ],
    );

    await dao.salvar(original);
    final lido = (await dao.buscarPorId('ponto-1'))!;

    expect(lido.nome, original.nome);
    expect(lido.identificador, original.identificador);
    expect(lido.bairro, 'Centro');
    expect(lido.dosagemMl, 120);
    expect(lido.distanciaEntreSubpontosMetros, 150);
    expect(lido.quantidadeDeSubpontos, 3);
    expect(lido.vazao, closeTo(original.vazao, 1e-9));
    expect(lido.aplicadorId, 'aplicador-1');
    expect(lido.estado, EstadoPontoDeAplicacao.ativa);
    expect(lido.agendamento, original.agendamento);
    expect(
      [for (final d in lido.agendamento!.datas) d.status],
      [StatusDataAgendada.pendente, StatusDataAgendada.concluida],
    );
    expect([for (final s in lido.subpontos) s.id], ['s-1', 's-2']);
  });

  test('guarda a tolerância de atraso e a remoção manual do alerta', () async {
    final base = pontoDeTeste('ponto-1').editarTolerancia(9);
    final datas = base.agendamento!.datas;
    final removidoEm = DateTime.utc(2026, 10, 28, 14, 30);
    await dao.salvar(
      base.copyWith(
        agendamento: base.agendamento!.copyWith(
          datas: [
            DataAgendada(
              id: datas.first.id,
              data: datas.first.data,
              alertaRemovidoEm: removidoEm,
            ),
            datas.last,
          ],
        ),
      ),
    );

    final lido = (await dao.buscarPorId('ponto-1'))!;

    expect(lido.toleranciaDias, 9);
    expect(
      lido.agendamento!.datas.first.alertaRemovidoEm!.isAtSameMomentAs(removidoEm),
      isTrue,
    );
    expect(lido.agendamento!.datas.last.alertaRemovidoEm, isNull);
  });

  test('ponto ainda sem aplicador e sem agendamento volta sem eles', () async {
    await dao.salvar(
      pontoDeTeste(
        'ponto-1',
        aplicadorId: null,
        estado: EstadoPontoDeAplicacao.enderecada,
        comAgendamento: false,
      ),
    );

    final lido = (await dao.buscarPorId('ponto-1'))!;

    expect(lido.aplicadorId, isNull);
    expect(lido.agendamento, isNull);
    expect(lido.estado, EstadoPontoDeAplicacao.enderecada);
  });

  test('buscarPorId devolve null para id desconhecido', () async {
    expect(await dao.buscarPorId('nao-existe'), isNull);
  });

  test('salvar de novo atualiza o ponto e troca as datas agendadas', () async {
    await dao.salvar(pontoDeTeste('ponto-1'));

    await dao.salvar(
      pontoDeTeste('ponto-1', nome: 'Nome novo', comAgendamento: false),
    );

    final lido = (await dao.buscarPorId('ponto-1'))!;
    expect(lido.nome, 'Nome novo');
    expect(lido.agendamento, isNull);
    final datas = await banco.db.query('datas_agendadas');
    expect(datas, isEmpty);
  });

  test('salvar não duplica subponto que o servidor devolve de novo', () async {
    final ponto = pontoDeTeste('ponto-1', subpontos: [subpontoDeTeste('s-1')]);

    await dao.salvar(ponto);
    await dao.salvar(ponto);

    expect((await dao.buscarPorId('ponto-1'))!.subpontos, hasLength(1));
  });

  test(
    'salvar preserva o subponto feito neste aparelho e ainda não sincronizado',
    () async {
      await dao.salvar(pontoDeTeste('ponto-1'));
      final aplicacao = aplicacaoDeTeste(
        'app-1',
        subpontos: [subpontoDeTeste('local-1')],
      );
      await AplicacaoDaoSqflite(banco.db).gravarComOutbox(aplicacao, [
        itemDoSubponto(aplicacao, aplicacao.subpontos.single),
      ]);

      // Pull seguinte, sem o subponto local.
      await dao.salvar(pontoDeTeste('ponto-1', nome: 'Atualizado'));

      final lido = (await dao.buscarPorId('ponto-1'))!;
      expect(lido.nome, 'Atualizado');
      expect([for (final s in lido.subpontos) s.id], ['local-1']);
    },
  );

  test(
    'subponto do pull que depois entra numa aplicação local passa a ser dela',
    () async {
      await dao.salvar(
        pontoDeTeste('ponto-1', subpontos: [subpontoDeTeste('s-1')]),
      );
      final aplicacao = aplicacaoDeTeste(
        'app-1',
        subpontos: [subpontoDeTeste('s-1')],
      );

      await AplicacaoDaoSqflite(banco.db).gravarComOutbox(aplicacao, [
        itemDoSubponto(aplicacao, aplicacao.subpontos.single),
      ]);
      await dao.remover('ponto-1');

      final linhas = await banco.db.query('subpontos');
      expect(linhas.single['aplicacao_id'], 'app-1');
    },
  );

  test('salvarTodos grava vários pontos numa transação', () async {
    await dao.salvarTodos([pontoDeTeste('a'), pontoDeTeste('b')]);

    expect(await dao.listar(), hasLength(2));
  });

  test('salvarTodos é atômico: um ponto inválido desfaz todos', () async {
    final invalido = pontoDeTeste('b');
    await banco.db.execute(
      'CREATE TRIGGER barra BEFORE INSERT ON pontos '
      "WHEN NEW.id = 'b' BEGIN SELECT RAISE(ABORT, 'recusado'); END",
    );

    await expectLater(
      dao.salvarTodos([pontoDeTeste('a'), invalido]),
      throwsA(anything),
    );

    expect(await dao.listar(), isEmpty);
  });

  group('listar', () {
    test('ordena por nome, sem diferenciar maiúsculas', () async {
      await dao.salvarTodos([
        pontoDeTeste('1', nome: 'córrego b'),
        pontoDeTeste('2', nome: 'Córrego A'),
      ]);

      final nomes = [for (final p in await dao.listar()) p.nome];

      expect(nomes, ['Córrego A', 'córrego b']);
    });

    test('filtra pelo aplicador', () async {
      await dao.salvarTodos([
        pontoDeTeste('1', aplicadorId: 'aplicador-1'),
        pontoDeTeste('2', aplicadorId: 'aplicador-2'),
      ]);

      final ids = [
        for (final p in await dao.listar(aplicadorId: 'aplicador-2')) p.id,
      ];

      expect(ids, ['2']);
    });
  });

  group('remover', () {
    test(
      'tira o ponto, as datas e os subpontos que vieram do servidor',
      () async {
        await dao.salvar(
          pontoDeTeste('ponto-1', subpontos: [subpontoDeTeste('s-1')]),
        );

        await dao.remover('ponto-1');

        expect(await dao.buscarPorId('ponto-1'), isNull);
        expect(await banco.db.query('datas_agendadas'), isEmpty);
        expect(await banco.db.query('subpontos'), isEmpty);
      },
    );

    test('mantém a aplicação, o subponto feito aqui e a outbox', () async {
      await dao.salvar(pontoDeTeste('ponto-1'));
      final aplicacao = aplicacaoDeTeste(
        'app-1',
        subpontos: [subpontoDeTeste('local-1')],
      );
      await AplicacaoDaoSqflite(banco.db).gravarComOutbox(aplicacao, [
        itemDoSubponto(aplicacao, aplicacao.subpontos.single),
      ]);

      await dao.remover('ponto-1');

      expect(await banco.db.query('aplicacoes'), hasLength(1));
      expect(await banco.db.query('subpontos'), hasLength(1));
      expect(await banco.db.query('outbox'), hasLength(1));
    });

    test('ponto desconhecido não é erro', () async {
      await expectLater(dao.remover('nao-existe'), completes);
    });
  });
}
