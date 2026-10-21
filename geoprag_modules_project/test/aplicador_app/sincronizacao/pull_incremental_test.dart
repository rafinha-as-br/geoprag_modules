import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/local/local.dart';
import 'package:geoprag_modules/aplicador_app/sincronizacao/sincronizacao.dart';
import 'package:geoprag_modules/src/api/api_exceptions.dart';
import 'package:geoprag_modules/src/api/sessao_segura.dart';
import 'package:geoprag_modules/src/api/sync/pull_dtos.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/armazenamento_em_memoria.dart';
import '../local/apoio_do_banco.dart';
import 'apoio_da_sincronizacao.dart';
import 'apoio_do_pull.dart';

/// Resposta de um pull incremental: só o que mudou, mais os `removidos`.
PullResponseDto respostaIncremental(
  List<Map<String, dynamic>> pontos, {
  List<String> removidos = const [],
  List<Map<String, dynamic>> produtos = const [],
  String? cursor,
}) => PullResponseDto.fromJson({
  ...corpoDoPull(pontos, produtos: produtos, cursor: cursor),
  'removidos': removidos,
});

Map<String, dynamic> corpoIncremental(
  List<Map<String, dynamic>> pontos, {
  List<String> removidos = const [],
  String? cursor,
}) => {...corpoDoPull(pontos, cursor: cursor), 'removidos': removidos};

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

  /// Retrato do que o banco guarda dos pontos, para comparar antes e depois.
  Future<List<String>> retratoDosPontos() async => [
    for (final p in await pontos.listar())
      '${p.id}|${p.nome}|${p.estado.name}|'
          '${[for (final d in p.agendamento?.datas ?? <DataAgendada>[]) d.status.name]}|'
          '${[for (final s in p.subpontos) s.id]}',
  ];

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

  group('ReconciliadorDoPull incremental', () {
    test('segundo pull sem mudanças não altera o banco local', () async {
      await reconciliador.reconciliar(
        respostaIncremental([pontoDoPull('ponto-1'), pontoDoPull('ponto-2')]),
      );
      final antes = await retratoDosPontos();

      final resultado = await reconciliador.reconciliar(
        respostaIncremental(const []),
        incremental: true,
      );

      expect(await retratoDosPontos(), antes);
      expect(resultado.incremental, isTrue);
      expect(resultado.pontosSalvos, isEmpty);
      expect(resultado.pontosRemovidos, isEmpty);
      expect(resultado.pontosMantidos, isEmpty);
    });

    test(
      'ponto que não veio na resposta não é tratado como retirado',
      () async {
        await pontos.salvar(pontoDeTeste('ponto-1'));
        await pontos.salvar(pontoDeTeste('ponto-2'));

        final resultado = await reconciliador.reconciliar(
          respostaIncremental([pontoDoPull('ponto-1', nome: 'Renomeado')]),
          incremental: true,
        );

        expect(await idsNoAparelho(), unorderedEquals(['ponto-1', 'ponto-2']));
        expect((await pontos.buscarPorId('ponto-1'))!.nome, 'Renomeado');
        expect(resultado.pontosRemovidos, isEmpty);
      },
    );

    test('só os `removidos` saem do aparelho', () async {
      await pontos.salvar(pontoDeTeste('ponto-1'));
      await pontos.salvar(pontoDeTeste('ponto-2'));
      await pontos.salvar(pontoDeTeste('ponto-3'));

      final resultado = await reconciliador.reconciliar(
        respostaIncremental(const [], removidos: ['ponto-2']),
        incremental: true,
      );

      expect(await idsNoAparelho(), unorderedEquals(['ponto-1', 'ponto-3']));
      expect(resultado.pontosRemovidos, ['ponto-2']);
    });

    test(
      'remoção de atribuição não apaga ponto com registro pendente',
      () async {
        await pontos.salvar(pontoDeTeste('ponto-1'));
        await pontos.salvar(pontoDeTeste('ponto-2'));
        await registraAplicacaoCompleta('ponto-1');

        final resultado = await reconciliador.reconciliar(
          respostaIncremental(const [], removidos: ['ponto-1', 'ponto-2']),
          incremental: true,
        );

        expect(await idsNoAparelho(), ['ponto-1']);
        expect(resultado.pontosMantidos, ['ponto-1']);
        expect(resultado.pontosRemovidos, ['ponto-2']);
        expect(await outbox.pontoIdsComPendencias(), {'ponto-1'});
      },
    );

    test('ponto cujo registro já foi enviado pode ser removido', () async {
      await pontos.salvar(pontoDeTeste('ponto-1'));
      await registraAplicacaoCompleta('ponto-1');
      final ids = [for (var i = 1; i <= 3; i++) 'ponto-1-s$i'];
      await outbox.marcarEnviando(ids);
      await outbox.marcarEnviado(ids);

      final resultado = await reconciliador.reconciliar(
        respostaIncremental(const [], removidos: ['ponto-1']),
        incremental: true,
      );

      expect(resultado.pontosRemovidos, ['ponto-1']);
      expect(await idsNoAparelho(), isEmpty);
    });

    test('id removido que o aparelho não tem é ignorado', () async {
      await pontos.salvar(pontoDeTeste('ponto-1'));

      final resultado = await reconciliador.reconciliar(
        respostaIncremental(const [], removidos: ['ponto-que-nao-tenho']),
        incremental: true,
      );

      expect(resultado.pontosRemovidos, isEmpty);
      expect(resultado.pontosMantidos, isEmpty);
      expect(await idsNoAparelho(), ['ponto-1']);
    });

    test(
      'ponto que veio alterado e também em `removidos` não é removido',
      () async {
        await pontos.salvar(pontoDeTeste('ponto-1'));

        await reconciliador.reconciliar(
          respostaIncremental([pontoDoPull('ponto-1')], removidos: ['ponto-1']),
          incremental: true,
        );

        expect(await idsNoAparelho(), ['ponto-1']);
      },
    );

    test(
      'produtos do incremental são só os novos, e voltam no resultado',
      () async {
        final resultado = await reconciliador.reconciliar(
          respostaIncremental(
            const [],
            produtos: [
              {'id': 'produto-9', 'nome': 'Novo'},
            ],
          ),
          incremental: true,
        );

        expect([for (final p in resultado.produtos) p.id], ['produto-9']);
      },
    );

    test('o snapshot continua removendo o que saiu da resposta', () async {
      await pontos.salvar(pontoDeTeste('ponto-1'));
      await pontos.salvar(pontoDeTeste('ponto-2'));

      await reconciliador.reconciliar(
        respostaIncremental([pontoDoPull('ponto-1')]),
      );

      expect(await idsNoAparelho(), ['ponto-1']);
    });
  });

  group('ServicoDeSincronizacaoImpl com cursor', () {
    late ApiFalsa api;
    late ArmazenamentoEmMemoria armazenamento;
    late CursorDoPull cursor;
    late ServicoDeSincronizacaoImpl servico;

    /// Cursor de 10h e, se o banco está vazio, um ponto: com o banco vazio o
    /// serviço ignora o cursor e pede o snapshot.
    Future<void> comCursor() async {
      await cursor.gravar(DateTime.utc(2026, 10, 21, 10));
      if (await reconciliador.semPontos()) {
        await pontos.salvar(pontoDeTeste('ponto-semente'));
      }
    }

    When<Future<Object?>> snapshot() => when(() => api.get('/sync/pull'));
    When<Future<Object?>> incremental() =>
        when(() => api.get('/sync/pull', query: any(named: 'query')));

    /// O `desde` de cada pull incremental feito, na ordem.
    List<Object?> desdesEnviados() => [
      for (final chamada in verify(
        () => api.get('/sync/pull', query: captureAny(named: 'query')),
      ).captured)
        (chamada as Map<String, dynamic>)['desde'],
    ];

    setUpAll(() {
      registerFallbackValue(<String, dynamic>{});
      registerFallbackValue(
        const PullResponseDto(pontos: [], produtos: [], removidos: []),
      );
    });

    setUp(() {
      api = ApiFalsa();
      armazenamento = ArmazenamentoEmMemoria();
      cursor = CursorDoPull(armazenamento);
      servico = ServicoDeSincronizacaoImpl(
        api: api,
        outbox: outbox,
        reconciliador: reconciliador,
        dispositivoId: () async => 'aparelho-1',
        cursor: cursor,
      );
    });

    test(
      'primeiro pull é o snapshot, sem `desde`, e guarda o cursor',
      () async {
        snapshot().thenAnswer(
          (_) async => corpoIncremental([
            pontoDoPull('ponto-1'),
          ], cursor: '2026-10-21T10:00:00Z'),
        );

        final resultado = await servico.sincronizar();

        expect(resultado.concluida, isTrue);
        expect(resultado.pull!.incremental, isFalse);
        expect(await cursor.ler(), DateTime.utc(2026, 10, 21, 10));
        verifyNever(
          () => api.get(
            '/sync/pull',
            query: any(named: 'query', that: isNotNull),
          ),
        );
      },
    );

    test('pull seguinte envia o cursor como `desde` e é incremental', () async {
      await comCursor();
      incremental().thenAnswer(
        (_) async => corpoIncremental(const [], cursor: '2026-10-21T11:00:00Z'),
      );

      final resultado = await servico.sincronizar();

      expect(resultado.pull!.incremental, isTrue);
      expect(desdesEnviados(), ['2026-10-21T10:00:00+00:00']);
      expect(await cursor.ler(), DateTime.utc(2026, 10, 21, 11));
    });

    test('segundo pull sem mudanças não altera o banco', () async {
      snapshot().thenAnswer(
        (_) async => corpoIncremental([
          pontoDoPull('ponto-1'),
          pontoDoPull('ponto-2'),
        ], cursor: '2026-10-21T10:00:00Z'),
      );
      await servico.sincronizar();
      final antes = await retratoDosPontos();
      incremental().thenAnswer(
        (_) async => corpoIncremental(const [], cursor: '2026-10-21T10:05:00Z'),
      );

      final resultado = await servico.sincronizar();

      expect(await retratoDosPontos(), antes);
      expect(resultado.pull!.pontosSalvos, isEmpty);
      expect(resultado.pull!.pontosRemovidos, isEmpty);
    });

    test(
      'cursor recusado pelo servidor cai para o snapshot e é refeito',
      () async {
        await pontos.salvar(pontoDeTeste('ponto-velho'));
        await comCursor();
        incremental().thenThrow(
          const RequisicaoInvalidaException('desde inválido', status: 422),
        );
        snapshot().thenAnswer(
          (_) async => corpoIncremental([
            pontoDoPull('ponto-1'),
          ], cursor: '2026-10-21T12:00:00Z'),
        );

        final resultado = await servico.sincronizar();

        expect(resultado.concluida, isTrue);
        expect(resultado.pull!.incremental, isFalse);
        // O snapshot varre o que saiu da resposta.
        expect(await idsNoAparelho(), ['ponto-1']);
        expect(await cursor.ler(), DateTime.utc(2026, 10, 21, 12));
      },
    );

    test('cursor que sobreviveu a um banco recriado é ignorado', () async {
      await cursor.gravar(DateTime.utc(2026, 10, 21, 10));
      snapshot().thenAnswer(
        (_) async => corpoIncremental([
          pontoDoPull('ponto-1'),
        ], cursor: '2026-10-21T12:00:00Z'),
      );

      final resultado = await servico.sincronizar();

      expect(resultado.pull!.incremental, isFalse);
      expect(await idsNoAparelho(), ['ponto-1']);
      expect(await cursor.ler(), DateTime.utc(2026, 10, 21, 12));
      verifyNever(
        () => api.get(
          '/sync/pull',
          query: any(named: 'query', that: isNotNull),
        ),
      );
    });

    test('cursor guardado ilegível vale como sem cursor', () async {
      armazenamento.dados[SessaoSegura.chaveDoCursorDoPull] = 'lixo';
      snapshot().thenAnswer(
        (_) async => corpoIncremental(const [], cursor: '2026-10-21T12:00:00Z'),
      );

      final resultado = await servico.sincronizar();

      expect(resultado.pull!.incremental, isFalse);
      expect(await cursor.ler(), DateTime.utc(2026, 10, 21, 12));
    });

    test('pull que falha por rede mantém o cursor', () async {
      await comCursor();
      incremental().thenThrow(const FalhaDeConexaoException('sem rede'));

      final resultado = await servico.sincronizar();

      expect(resultado.pullFalhou, isTrue);
      expect(await cursor.ler(), DateTime.utc(2026, 10, 21, 10));
    });

    test('envio que falha antes do pull deixa o cursor onde estava', () async {
      await pontos.salvar(pontoDeTeste('ponto-1'));
      await registraAplicacaoCompleta('ponto-1');
      await comCursor();
      when(
        () => api.post(any(), corpo: any(named: 'corpo')),
      ).thenThrow(const FalhaDeConexaoException('sem rede'));

      final resultado = await servico.sincronizar();

      expect(resultado.pull, isNull);
      expect(resultado.pullFalhou, isTrue);
      expect(await cursor.ler(), DateTime.utc(2026, 10, 21, 10));
      expect(await idsNoAparelho(), ['ponto-1']);
    });

    test(
      'ponto retirado enviado antes do pull sai e o cursor avança',
      () async {
        await pontos.salvar(pontoDeTeste('ponto-1'));
        await registraAplicacaoCompleta('ponto-1');
        await comCursor();
        when(() => api.post(any(), corpo: any(named: 'corpo'))).thenAnswer(
          (_) async => respostaDoLote([
            for (var i = 1; i <= 3; i++) criado('ponto-1-s$i'),
          ]),
        );
        incremental().thenAnswer(
          (_) async => corpoIncremental(
            const [],
            removidos: ['ponto-1'],
            cursor: '2026-10-21T11:00:00Z',
          ),
        );

        final resultado = await servico.sincronizar();

        expect(resultado.pull!.pontosRemovidos, ['ponto-1']);
        expect(await idsNoAparelho(), isEmpty);
        expect(await cursor.ler(), DateTime.utc(2026, 10, 21, 11));
      },
    );

    test(
      'ponto retirado que ficou por pendência impede o cursor de avançar',
      () async {
        await comCursor();
        final falso = _ReconciliadorFalso();
        when(falso.semPontos).thenAnswer((_) async => false);
        when(
          () =>
              falso.reconciliar(any(), incremental: any(named: 'incremental')),
        ).thenAnswer(
          (_) async => ResultadoDoPull(
            incremental: true,
            pontosMantidos: const ['ponto-1'],
            cursor: DateTime.utc(2026, 10, 21, 11),
          ),
        );
        incremental().thenAnswer(
          (_) async => corpoIncremental(
            const [],
            removidos: ['ponto-1'],
            cursor: '2026-10-21T11:00:00Z',
          ),
        );
        final comFalso = ServicoDeSincronizacaoImpl(
          api: api,
          outbox: outbox,
          reconciliador: falso,
          dispositivoId: () async => 'aparelho-1',
          cursor: cursor,
        );

        await comFalso.sincronizar();

        // O próximo pull parte do cursor antigo e traz o `removidos` de novo.
        expect(await cursor.ler(), DateTime.utc(2026, 10, 21, 10));
      },
    );

    test('ponto ilegível na resposta impede o cursor de avançar', () async {
      await comCursor();
      incremental().thenAnswer(
        (_) async => corpoIncremental([
          pontoDoPull('ponto-ruim', estado: 'ESTADO_NOVO'),
        ], cursor: '2026-10-21T11:00:00Z'),
      );

      final resultado = await servico.sincronizar();

      expect(resultado.pull!.pontosIgnorados, ['ponto-ruim']);
      expect(await cursor.ler(), DateTime.utc(2026, 10, 21, 10));
    });

    test('resposta sem cursor não grava nem apaga o cursor', () async {
      await comCursor();
      incremental().thenAnswer((_) async => corpoIncremental(const []));

      await servico.sincronizar();

      expect(await cursor.ler(), DateTime.utc(2026, 10, 21, 10));
    });

    test('falha ao gravar o cursor não derruba o pull', () async {
      final quebrado = ServicoDeSincronizacaoImpl(
        api: api,
        outbox: outbox,
        reconciliador: reconciliador,
        dispositivoId: () async => 'aparelho-1',
        cursor: CursorDoPull(_ArmazenamentoQueFalhaAoGravar()),
      );
      snapshot().thenAnswer(
        (_) async => corpoIncremental([
          pontoDoPull('ponto-1'),
        ], cursor: '2026-10-21T10:00:00Z'),
      );

      final resultado = await quebrado.sincronizar();

      expect(resultado.concluida, isTrue);
      expect(await idsNoAparelho(), ['ponto-1']);
    });

    test('sem CursorDoPull o pull é sempre o snapshot', () async {
      final semCursor = ServicoDeSincronizacaoImpl(
        api: api,
        outbox: outbox,
        reconciliador: reconciliador,
        dispositivoId: () async => 'aparelho-1',
      );
      snapshot().thenAnswer(
        (_) async => corpoIncremental(const [], cursor: '2026-10-21T10:00:00Z'),
      );

      await semCursor.sincronizar();
      await semCursor.sincronizar();

      verify(() => api.get('/sync/pull')).called(2);
    });
  });

  group('CursorDoPull', () {
    test('logout ou novo login apaga o cursor junto com a sessão', () async {
      final armazenamento = ArmazenamentoEmMemoria();
      await CursorDoPull(armazenamento).gravar(DateTime.utc(2026, 10, 21, 10));

      await SessaoSegura(armazenamento: armazenamento).limpar();

      expect(await CursorDoPull(armazenamento).ler(), isNull);
    });

    test('ler devolve o instante gravado', () async {
      final armazenamento = ArmazenamentoEmMemoria();
      final cursor = CursorDoPull(armazenamento);

      expect(await cursor.ler(), isNull);
      await cursor.gravar(DateTime.utc(2026, 10, 21, 10, 0, 0, 123, 456));

      expect(await cursor.ler(), DateTime.parse('2026-10-21T10:00:00.123456Z'));
      await cursor.apagar();
      expect(await cursor.ler(), isNull);
    });
  });
}

class _ArmazenamentoQueFalhaAoGravar extends ArmazenamentoEmMemoria {
  @override
  Future<void> gravar(String chave, String valor) =>
      Future.error(StateError('armazenamento indisponível'));
}

class _ReconciliadorFalso extends Mock implements ReconciliadorDoPull {}
