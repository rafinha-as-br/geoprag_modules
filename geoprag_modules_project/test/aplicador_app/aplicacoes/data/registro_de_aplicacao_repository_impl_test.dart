import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/aplicacoes.dart';
import 'package:geoprag_modules/aplicador_app/local/local.dart';
import 'package:geoprag_modules/aplicador_app/sincronizacao/sincronizacao.dart';
import 'package:geoprag_modules/src/api/api_exceptions.dart';
import 'package:geoprag_modules/src/entities/aplicacao.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:geoprag_modules/src/services/gerador_de_id.dart';
import 'package:mocktail/mocktail.dart';

import '../../local/apoio_do_banco.dart';
import '../../sincronizacao/apoio_da_sincronizacao.dart';

void main() {
  late BancoLocal banco;
  late AplicacaoDaoSqflite aplicacoes;
  late OutboxDaoSqflite outbox;
  late ApiFalsa api;

  const localizacao = LocalizacaoCapturada(latitude: -26.91, longitude: -48.92);
  final agora = DateTime.utc(2026, 10, 21, 12);

  RegistroDeAplicacaoRepositoryImpl criarRepositorio(
    ServicoDeSincronizacao sincronizacao, {
    GeradorDeId? gerador,
  }) => RegistroDeAplicacaoRepositoryImpl(
    aplicacoes: aplicacoes,
    sincronizacao: sincronizacao,
    gerador: gerador ?? GeradorSequencial(),
    agora: () => agora,
  );

  ServicoDeSincronizacaoImpl servicoReal() => ServicoDeSincronizacaoImpl(
    api: api,
    outbox: outbox,
    reconciliador: reconciliadorDe(banco),
    dispositivoId: () async => 'aparelho-1',
  );

  Future<Aplicacao> iniciar(RegistroDeAplicacaoRepository repositorio) =>
      repositorio.iniciarAplicacao(
        pontoId: 'ponto-1',
        aplicadorId: 'aplicador-1',
        dataAgendadaId: 'ponto-1-d1',
        produtoId: 'produto-1',
        localizacao: localizacao,
      );

  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  setUp(() async {
    banco = await abrirBancoEmMemoria();
    aplicacoes = AplicacaoDaoSqflite(banco.db);
    outbox = OutboxDaoSqflite(banco.db);
    api = ApiFalsa();
  });

  tearDown(() => banco.fechar());

  group('iniciarAplicacao', () {
    test('grava a aplicação sem subpontos e sem nada na outbox', () async {
      final repositorio = criarRepositorio(ServicoFalso());

      final aplicacao = await iniciar(repositorio);

      expect(aplicacao.id, 'id-1');
      expect(aplicacao.subpontos, isEmpty);
      expect(aplicacao.realizadoEm, agora);
      expect(aplicacao.localizacao, localizacao);
      expect((await aplicacoes.buscarPorId('id-1'))!.pontoId, 'ponto-1');
      expect(await outbox.pendentes(), isEmpty);
    });

    test('não dispara envio: ainda não há o que enviar', () async {
      final servico = ServicoFalso();

      await iniciar(criarRepositorio(servico));

      verifyNever(() => servico.enviarPendentes());
    });
  });

  group('registrarSubponto', () {
    test(
      'grava o subponto e o item PENDENTE da outbox, com o id do subponto',
      () async {
        final servico = ServicoFalso();
        when(() => servico.enviarPendentes()).thenAnswer((_) async {});
        final repositorio = criarRepositorio(servico);
        final aplicacao = await iniciar(repositorio);

        final atualizada = await repositorio.registrarSubponto(
          aplicacaoId: aplicacao.id,
          latitude: -26.9,
          longitude: -48.9,
        );

        final subponto = atualizada.subpontos.single;
        expect(subponto.id, 'id-2');
        expect(subponto.latitude, -26.9);
        expect(subponto.realizadoEm, agora);
        final item = (await outbox.buscarPorId(subponto.id))!;
        expect(item.estado, EstadoDoItemDaOutbox.pendente);
        expect(item.pontoId, 'ponto-1');
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        expect(payload['id'], subponto.id);
        expect(payload['aplicacaoId'], aplicacao.id);
        expect(payload['dataAgendadaId'], 'ponto-1-d1');
        expect(payload['produtoId'], 'produto-1');
        expect(
          (await aplicacoes.buscarPorId(aplicacao.id))!.subpontos.single.id,
          subponto.id,
        );
      },
    );

    test(
      'vários subpontos entram em itens distintos da mesma aplicação',
      () async {
        final servico = ServicoFalso();
        when(() => servico.enviarPendentes()).thenAnswer((_) async {});
        final repositorio = criarRepositorio(servico);
        final aplicacao = await iniciar(repositorio);

        await repositorio.registrarSubponto(
          aplicacaoId: aplicacao.id,
          latitude: 1,
          longitude: 1,
        );
        final final_ = await repositorio.registrarSubponto(
          aplicacaoId: aplicacao.id,
          latitude: 2,
          longitude: 2,
        );

        expect(final_.subpontos.map((s) => s.id), ['id-2', 'id-3']);
        expect(await outbox.pendentes(), hasLength(2));
        expect(
          (await aplicacoes.listarPorPonto('ponto-1')).single.subpontos,
          hasLength(2),
        );
      },
    );

    test('dispara o envio depois de gravar, sem esperar por ele', () async {
      final servico = ServicoFalso();
      final nuncaTermina = Completer<void>();
      when(
        () => servico.enviarPendentes(),
      ).thenAnswer((_) => nuncaTermina.future);
      final repositorio = criarRepositorio(servico);
      final aplicacao = await iniciar(repositorio);

      final atualizada = await repositorio
          .registrarSubponto(
            aplicacaoId: aplicacao.id,
            latitude: 1,
            longitude: 1,
          )
          .timeout(const Duration(seconds: 2));

      expect(atualizada.subpontos, hasLength(1));
      verify(() => servico.enviarPendentes()).called(1);
    });

    test('se o envio falha, o registro conclui do mesmo jeito', () async {
      final servico = ServicoFalso();
      when(() => servico.enviarPendentes()).thenThrow(StateError('boom'));
      final repositorio = criarRepositorio(servico);
      final aplicacao = await iniciar(repositorio);

      final atualizada = await repositorio.registrarSubponto(
        aplicacaoId: aplicacao.id,
        latitude: 1,
        longitude: 1,
      );

      expect(atualizada.subpontos, hasLength(1));
      expect(await outbox.pendentes(), hasLength(1));
    });

    test(
      'aplicação inexistente lança EntidadeNaoEncontradaException',
      () async {
        final repositorio = criarRepositorio(ServicoFalso());

        expect(
          () => repositorio.registrarSubponto(
            aplicacaoId: 'nao-existe',
            latitude: 1,
            longitude: 1,
          ),
          throwsA(isA<EntidadeNaoEncontradaException>()),
        );
      },
    );

    test(
      'é atômico: se a outbox recusa o item, o subponto também não entra',
      () async {
        final servico = ServicoFalso();
        when(() => servico.enviarPendentes()).thenAnswer((_) async {});
        // O gerador repete o id do subponto: o segundo item colide na outbox.
        final repositorio = criarRepositorio(
          servico,
          gerador: _GeradorQueRepete(['app-1', 'sub-1', 'sub-1']),
        );
        final aplicacao = await iniciar(repositorio);
        await repositorio.registrarSubponto(
          aplicacaoId: aplicacao.id,
          latitude: 1,
          longitude: 1,
        );

        await expectLater(
          repositorio.registrarSubponto(
            aplicacaoId: aplicacao.id,
            latitude: 2,
            longitude: 2,
          ),
          throwsA(isA<Exception>()),
        );

        final guardada = (await aplicacoes.buscarPorId(aplicacao.id))!;
        expect(guardada.subpontos, hasLength(1));
        expect(guardada.subpontos.single.latitude, 1);
        expect(await outbox.pendentes(), hasLength(1));
      },
    );
  });

  group('com o serviço de sincronização real', () {
    test('sem rede: o registro conclui e fica PENDENTE na outbox', () async {
      postDoLote(api).thenThrow(const FalhaDeConexaoException('Sem conexão.'));
      final servico = servicoReal();
      final repositorio = criarRepositorio(servico);
      final aplicacao = await iniciar(repositorio);

      final atualizada = await repositorio.registrarSubponto(
        aplicacaoId: aplicacao.id,
        latitude: 1,
        longitude: 1,
      );
      await servico.enviarPendentes(); // espera o envio disparado terminar

      final item = (await outbox.buscarPorId(atualizada.subpontos.single.id))!;
      expect(item.estado, EstadoDoItemDaOutbox.pendente);
      expect(item.ultimoErro, 'Sem conexão.');
      expect(atualizada.subpontos, hasLength(1));
    });

    test('com rede: o mesmo fluxo envia e marca ENVIADO', () async {
      postDoLote(api).thenAnswer((inv) async {
        final lote = inv.namedArguments[#corpo] as Map<String, dynamic>;
        return respostaDoLote([
          for (final i in lote['itens'] as List<dynamic>)
            criado((i as Map)['id'] as String),
        ]);
      });
      final servico = servicoReal();
      final repositorio = criarRepositorio(servico);
      final aplicacao = await iniciar(repositorio);

      final atualizada = await repositorio.registrarSubponto(
        aplicacaoId: aplicacao.id,
        latitude: 1,
        longitude: 1,
      );
      await servico.enviarPendentes();

      final item = (await outbox.buscarPorId(atualizada.subpontos.single.id))!;
      expect(item.estado, EstadoDoItemDaOutbox.enviado);
    });

    test('o servidor recusa: o item fica REJEITADO com o motivo', () async {
      postDoLote(api).thenAnswer((inv) async {
        final lote = inv.namedArguments[#corpo] as Map<String, dynamic>;
        return respostaDoLote([
          for (final i in lote['itens'] as List<dynamic>)
            rejeitado(
              (i as Map)['id'] as String,
              motivo: 'O produto informado não existe.',
            ),
        ]);
      });
      final servico = servicoReal();
      final repositorio = criarRepositorio(servico);
      final aplicacao = await iniciar(repositorio);

      final atualizada = await repositorio.registrarSubponto(
        aplicacaoId: aplicacao.id,
        latitude: 1,
        longitude: 1,
      );
      await servico.enviarPendentes();

      final item = (await outbox.buscarPorId(atualizada.subpontos.single.id))!;
      expect(item.estado, EstadoDoItemDaOutbox.rejeitado);
      expect(item.ultimoErro, 'O produto informado não existe.');
    });
  });
}

/// Devolve os ids na ordem dada (e repete o último se acabarem).
class _GeradorQueRepete implements GeradorDeId {
  _GeradorQueRepete(this._ids);

  final List<String> _ids;
  int _i = 0;

  @override
  String gerar() => _ids[_i < _ids.length ? _i++ : _ids.length - 1];
}
