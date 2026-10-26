import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/local/local.dart';
import 'package:geoprag_modules/aplicador_app/sincronizacao/sincronizacao.dart';
import 'package:geoprag_modules/src/api/api_exceptions.dart';
import 'package:mocktail/mocktail.dart';

import '../local/apoio_do_banco.dart';
import 'apoio_da_sincronizacao.dart';
import 'apoio_do_pull.dart';

void main() {
  late BancoLocal banco;
  late AplicacaoDaoSqflite aplicacoes;
  late OutboxDaoSqflite outbox;
  late ApiFalsa api;

  ServicoDeSincronizacaoImpl criarServico({int tamanhoDoLote = 500}) =>
      ServicoDeSincronizacaoImpl(
        api: api,
        outbox: outbox,
        reconciliador: reconciliadorDe(banco),
        dispositivoId: () async => 'aparelho-1',
        tamanhoDoLote: tamanhoDoLote,
      );

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() async {
    banco = await abrirBancoEmMemoria();
    aplicacoes = AplicacaoDaoSqflite(banco.db);
    outbox = OutboxDaoSqflite(banco.db);
    api = ApiFalsa();
  });

  tearDown(() => banco.fechar());

  Future<ItemDaOutbox> item(String id) async => (await outbox.buscarPorId(id))!;

  group('com rede', () {
    test('CRIADO e DUPLICADO marcam ENVIADO e o lote leva o dispositivo e os '
        'itens gravados', () async {
      await enfileira(aplicacoes, 's-1');
      await enfileira(aplicacoes, 's-2', minutos: 1);
      postDoLote(api).thenAnswer(
        (_) async => respostaDoLote([criado('s-1'), duplicado('s-2')]),
      );

      await criarServico().enviarPendentes();

      expect((await item('s-1')).estado, EstadoDoItemDaOutbox.enviado);
      expect((await item('s-2')).estado, EstadoDoItemDaOutbox.enviado);
      expect((await item('s-1')).tentativas, 1);
      final lote = lotesEnviados(api).single;
      expect(lote['dispositivoId'], 'aparelho-1');
      final itens = lote['itens'] as List<dynamic>;
      expect([for (final i in itens) (i as Map)['id']], ['s-1', 's-2']);
      // O que vai é exatamente o payload gravado no momento do registro.
      expect(itens.first, jsonDecode((await item('s-1')).payload));
    });

    test('REJEITADO marca REJEITADO com o motivo do servidor', () async {
      await enfileira(aplicacoes, 's-1');
      postDoLote(api).thenAnswer(
        (_) async => respostaDoLote([
          rejeitado(
            's-1',
            codigo: 'PONTO_INEXISTENTE',
            motivo: 'O ponto informado não existe.',
          ),
        ]),
      );

      await criarServico().enviarPendentes();

      final recusado = await item('s-1');
      expect(recusado.estado, EstadoDoItemDaOutbox.rejeitado);
      expect(recusado.ultimoErro, 'O ponto informado não existe.');
    });

    test(
      'rejeição sem motivo usa o código, e sem código um texto padrão',
      () async {
        await enfileira(aplicacoes, 's-1');
        await enfileira(aplicacoes, 's-2', minutos: 1);
        postDoLote(api).thenAnswer(
          (_) async => respostaDoLote([
            rejeitado('s-1', codigo: 'DADOS_INVALIDOS'),
            rejeitado('s-2'),
          ]),
        );

        await criarServico().enviarPendentes();

        expect((await item('s-1')).ultimoErro, 'DADOS_INVALIDOS');
        expect(
          (await item('s-2')).ultimoErro,
          'Registro recusado pelo servidor.',
        );
      },
    );

    test('lote misto: cada item recebe o destino do seu resultado', () async {
      await enfileira(aplicacoes, 's-1');
      await enfileira(aplicacoes, 's-2', minutos: 1);
      await enfileira(aplicacoes, 's-3', minutos: 2);
      postDoLote(api).thenAnswer(
        (_) async => respostaDoLote([
          // Fora de ordem de propósito: o casamento é pelo id.
          rejeitado('s-2', motivo: 'Produto inexistente.'),
          criado('s-3'),
          duplicado('s-1'),
        ]),
      );

      await criarServico().enviarPendentes();

      expect((await item('s-1')).estado, EstadoDoItemDaOutbox.enviado);
      expect((await item('s-2')).estado, EstadoDoItemDaOutbox.rejeitado);
      expect((await item('s-3')).estado, EstadoDoItemDaOutbox.enviado);
    });

    test('sem pendentes não chama a API', () async {
      await criarServico().enviarPendentes();

      verifyNever(() => api.post(any(), corpo: any(named: 'corpo')));
    });

    test(
      'item que o servidor não menciona volta à fila e o fluxo para',
      () async {
        await enfileira(aplicacoes, 's-1');
        await enfileira(aplicacoes, 's-2', minutos: 1);
        postDoLote(
          api,
        ).thenAnswer((_) async => respostaDoLote([criado('s-1')]));

        await criarServico().enviarPendentes();

        expect((await item('s-1')).estado, EstadoDoItemDaOutbox.enviado);
        final sem = await item('s-2');
        expect(sem.estado, EstadoDoItemDaOutbox.pendente);
        expect(sem.ultimoErro, isNotNull);
        verify(() => api.post(any(), corpo: any(named: 'corpo'))).called(1);
      },
    );

    test('payload ilegível é REJEITADO sem travar o resto da fila', () async {
      final corrompida = aplicacaoDeTeste('app-x');
      await aplicacoes.gravarComOutbox(corrompida, [
        ItemDaOutbox.novo(
          id: 'ruim',
          tipo: TipoDoItemDaOutbox.subponto,
          pontoId: 'ponto-1',
          payload: 'isto não é json',
          criadoEm: agoraDeTeste,
        ),
      ]);
      await enfileira(aplicacoes, 's-1', minutos: 1);
      postDoLote(api).thenAnswer((_) async => respostaDoLote([criado('s-1')]));

      await criarServico().enviarPendentes();

      expect((await item('ruim')).estado, EstadoDoItemDaOutbox.rejeitado);
      expect((await item('s-1')).estado, EstadoDoItemDaOutbox.enviado);
    });

    test('fatia a fila em lotes do tamanho configurado', () async {
      for (var i = 1; i <= 5; i++) {
        await enfileira(aplicacoes, 's-$i', minutos: i);
      }
      postDoLote(api).thenAnswer((inv) async {
        final lote = inv.namedArguments[#corpo] as Map<String, dynamic>;
        return respostaDoLote([
          for (final i in lote['itens'] as List<dynamic>)
            criado((i as Map)['id'] as String),
        ]);
      });

      await criarServico(tamanhoDoLote: 2).enviarPendentes();

      final tamanhos = [
        for (final lote in lotesEnviados(api)) (lote['itens'] as List).length,
      ];
      expect(tamanhos, [2, 2, 1]);
      expect((await outbox.contarPorEstado())[EstadoDoItemDaOutbox.enviado], 5);
    });
  });

  group('lote recusado por inteiro (400/413/422)', () {
    const recusa = RequisicaoInvalidaException(
      'Dados inválidos.',
      codigo: 'VALIDACAO_INVALIDA',
      status: 400,
    );

    test(
      'o item inválido fica REJEITADO sozinho e o resto da fila segue',
      () async {
        for (var i = 1; i <= 3; i++) {
          await enfileira(aplicacoes, 's-$i', minutos: i);
        }
        postDoLote(api).thenAnswer((inv) async {
          final lote = inv.namedArguments[#corpo] as Map<String, dynamic>;
          final ids = [
            for (final i in lote['itens'] as List<dynamic>) (i as Map)['id'],
          ];
          if (ids.contains('s-2')) throw recusa;
          return respostaDoLote([for (final id in ids) criado(id as String)]);
        });

        await criarServico().enviarPendentes();

        expect((await item('s-1')).estado, EstadoDoItemDaOutbox.enviado);
        expect((await item('s-3')).estado, EstadoDoItemDaOutbox.enviado);
        final ruim = await item('s-2');
        expect(ruim.estado, EstadoDoItemDaOutbox.rejeitado);
        expect(ruim.ultimoErro, 'Dados inválidos.');
      },
    );

    test(
      'lote de um item só: o item vira REJEITADO sem nova tentativa',
      () async {
        await enfileira(aplicacoes, 's-1');
        postDoLote(api).thenThrow(recusa);

        await criarServico().enviarPendentes();

        expect((await item('s-1')).estado, EstadoDoItemDaOutbox.rejeitado);
        verify(() => api.post(any(), corpo: any(named: 'corpo'))).called(1);
      },
    );

    test(
      'se a rede cai durante o item a item, o resto espera na fila',
      () async {
        for (var i = 1; i <= 3; i++) {
          await enfileira(aplicacoes, 's-$i', minutos: i);
        }
        var chamadas = 0;
        postDoLote(api).thenAnswer((inv) async {
          chamadas++;
          final lote = inv.namedArguments[#corpo] as Map<String, dynamic>;
          final ids = [
            for (final i in lote['itens'] as List<dynamic>) (i as Map)['id'],
          ];
          if (ids.length > 1) throw recusa; // o lote inteiro é recusado
          if (ids.single == 's-2') {
            throw const FalhaDeConexaoException('Sem conexão.');
          }
          return respostaDoLote([criado(ids.single as String)]);
        });

        await criarServico().enviarPendentes();

        expect((await item('s-1')).estado, EstadoDoItemDaOutbox.enviado);
        expect((await item('s-2')).estado, EstadoDoItemDaOutbox.pendente);
        expect((await item('s-3')).estado, EstadoDoItemDaOutbox.pendente);
        expect(chamadas, 3); // lote + s-1 + s-2; para sem tentar s-3
      },
    );
  });

  group('falha local depois de o servidor responder', () {
    test('o lote não fica preso em ENVIANDO', () async {
      await enfileira(aplicacoes, 's-1');
      postDoLote(api).thenAnswer((_) async => respostaDoLote([criado('s-1')]));
      final outboxQueFalha = _OutboxQueFalhaAoMarcarEnviado(outbox);
      final servico = ServicoDeSincronizacaoImpl(
        api: api,
        outbox: outboxQueFalha,
        reconciliador: reconciliadorDe(banco),
        dispositivoId: () async => 'aparelho-1',
      );

      await servico.enviarPendentes(); // não lança

      // `marcarEnviado` falhou; o item voltou à fila para ser reenviado (o
      // servidor responde DUPLICADO) em vez de ficar ENVIANDO para sempre.
      expect((await item('s-1')).estado, EstadoDoItemDaOutbox.pendente);
    });
  });

  group('sem rede (falha de requisição conta como offline)', () {
    final falhas = <String, Exception>{
      'sem conexão': const FalhaDeConexaoException('Sem conexão.'),
      'tempo esgotado': const FalhaDeConexaoException(
        'O servidor demorou para responder.',
        tempoEsgotado: true,
      ),
      'erro do servidor': const ErroDoServidorException(
        'O servidor encontrou um problema.',
        status: 503,
      ),
      'sessão sem renovação': const NaoAutenticadoException(
        'Sua sessão expirou. Entre novamente.',
      ),
    };

    for (final MapEntry(key: nome, value: falha) in falhas.entries) {
      test('$nome: o registro continua PENDENTE e nada é perdido', () async {
        await enfileira(aplicacoes, 's-1');
        await enfileira(aplicacoes, 's-2', minutos: 1);
        postDoLote(api).thenThrow(falha);

        await criarServico().enviarPendentes(); // não lança

        for (final id in ['s-1', 's-2']) {
          final pendente = await item(id);
          expect(pendente.estado, EstadoDoItemDaOutbox.pendente);
          expect(pendente.tentativas, 1);
          expect(pendente.ultimoErro, (falha as ApiException).mensagemAmigavel);
        }
      });
    }

    test(
      'depois de falhar, o reenvio manda o mesmo id e marca ENVIADO',
      () async {
        await enfileira(aplicacoes, 's-1');
        final servico = criarServico();
        postDoLote(
          api,
        ).thenThrow(const FalhaDeConexaoException('Sem conexão.'));
        await servico.enviarPendentes();
        expect((await item('s-1')).estado, EstadoDoItemDaOutbox.pendente);

        postDoLote(
          api,
        ).thenAnswer((_) async => respostaDoLote([criado('s-1')]));
        await servico.enviarPendentes();

        final enviado = await item('s-1');
        expect(enviado.estado, EstadoDoItemDaOutbox.enviado);
        expect(enviado.tentativas, 2);
        expect(enviado.ultimoErro, isNull);
        final ids = [
          for (final lote in lotesEnviados(api))
            for (final i in lote['itens'] as List<dynamic>) (i as Map)['id'],
        ];
        expect(ids, ['s-1', 's-1']);
      },
    );

    test('falha no meio: o que já foi enviado fica ENVIADO e o resto '
        'espera', () async {
      for (var i = 1; i <= 4; i++) {
        await enfileira(aplicacoes, 's-$i', minutos: i);
      }
      var chamadas = 0;
      postDoLote(api).thenAnswer((inv) async {
        chamadas++;
        if (chamadas == 2) {
          throw const FalhaDeConexaoException(
            'Tempo esgotado.',
            tempoEsgotado: true,
          );
        }
        final lote = inv.namedArguments[#corpo] as Map<String, dynamic>;
        return respostaDoLote([
          for (final i in lote['itens'] as List<dynamic>)
            criado((i as Map)['id'] as String),
        ]);
      });

      await criarServico(tamanhoDoLote: 2).enviarPendentes();

      expect((await item('s-1')).estado, EstadoDoItemDaOutbox.enviado);
      expect((await item('s-2')).estado, EstadoDoItemDaOutbox.enviado);
      expect((await item('s-3')).estado, EstadoDoItemDaOutbox.pendente);
      expect((await item('s-4')).estado, EstadoDoItemDaOutbox.pendente);
      expect(chamadas, 2); // não insiste depois da falha
    });

    test('erro inesperado também devolve o lote à fila e não escapa', () async {
      await enfileira(aplicacoes, 's-1');
      postDoLote(api).thenThrow(StateError('bug inesperado'));

      await criarServico().enviarPendentes();

      final pendente = await item('s-1');
      expect(pendente.estado, EstadoDoItemDaOutbox.pendente);
      expect(pendente.ultimoErro, isNot(contains('bug inesperado')));
    });

    test('resposta que não é um objeto JSON devolve o lote à fila', () async {
      await enfileira(aplicacoes, 's-1');
      postDoLote(api).thenAnswer((_) async => 'gateway caiu');

      await criarServico().enviarPendentes();

      expect((await item('s-1')).estado, EstadoDoItemDaOutbox.pendente);
    });
  });

  group('um fluxo por vez', () {
    test('duas chamadas simultâneas geram um único envio', () async {
      await enfileira(aplicacoes, 's-1');
      final liberar = Completer<void>();
      postDoLote(api).thenAnswer((_) async {
        await liberar.future;
        return respostaDoLote([criado('s-1')]);
      });
      final servico = criarServico();

      final primeira = servico.enviarPendentes();
      final segunda = servico.enviarPendentes();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      liberar.complete();
      await Future.wait([primeira, segunda]);

      verify(() => api.post(any(), corpo: any(named: 'corpo'))).called(1);
      expect((await item('s-1')).estado, EstadoDoItemDaOutbox.enviado);
    });

    test(
      'item que chega durante o envio é enviado na rodada seguinte',
      () async {
        await enfileira(aplicacoes, 's-1');
        final liberar = Completer<void>();
        var chamadas = 0;
        postDoLote(api).thenAnswer((inv) async {
          chamadas++;
          if (chamadas == 1) await liberar.future;
          final lote = inv.namedArguments[#corpo] as Map<String, dynamic>;
          return respostaDoLote([
            for (final i in lote['itens'] as List<dynamic>)
              criado((i as Map)['id'] as String),
          ]);
        });
        final servico = criarServico();

        final primeira = servico.enviarPendentes();
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await enfileira(aplicacoes, 's-2', minutos: 1);
        final segunda = servico.enviarPendentes(); // o registro novo pede envio
        liberar.complete();
        await Future.wait([primeira, segunda]);

        expect((await item('s-1')).estado, EstadoDoItemDaOutbox.enviado);
        expect((await item('s-2')).estado, EstadoDoItemDaOutbox.enviado);
      },
    );

    test('depois que termina, uma chamada nova começa outro fluxo', () async {
      await enfileira(aplicacoes, 's-1');
      postDoLote(api).thenAnswer((_) async => respostaDoLote([criado('s-1')]));
      final servico = criarServico();
      await servico.enviarPendentes();
      await enfileira(aplicacoes, 's-2', minutos: 1);
      postDoLote(api).thenAnswer((_) async => respostaDoLote([criado('s-2')]));

      await servico.enviarPendentes();

      expect((await item('s-2')).estado, EstadoDoItemDaOutbox.enviado);
    });
  });

  group('sincronizar (envio e pull)', () {
    late PontoDaoSqflite pontos;

    setUp(() => pontos = PontoDaoSqflite(banco.db));

    When<Future<Object?>> pull() => when(() => api.get('/sync/pull'));

    test('envia a outbox e só depois baixa os pontos', () async {
      await enfileira(aplicacoes, 's-1', pontoId: 'ponto-1');
      final ordem = <String>[];
      postDoLote(api).thenAnswer((_) async {
        ordem.add('envio');
        return respostaDoLote([criado('s-1')]);
      });
      pull().thenAnswer((_) async {
        ordem.add('pull');
        return corpoDoPull([pontoDoPull('ponto-1')]);
      });

      final resultado = await criarServico().sincronizar();

      expect(ordem, ['envio', 'pull']);
      expect(resultado.concluida, isTrue);
      expect(resultado.pull!.pontosSalvos, ['ponto-1']);
      expect(await pontos.buscarPorId('ponto-1'), isNotNull);
      expect((await item('s-1')).estado, EstadoDoItemDaOutbox.enviado);
    });

    test('com a outbox vazia, só baixa os pontos', () async {
      pull().thenAnswer((_) async => corpoDoPull([pontoDoPull('ponto-1')]));

      final resultado = await criarServico().sincronizar();

      verifyNever(() => api.post(any(), corpo: any(named: 'corpo')));
      expect(resultado.concluida, isTrue);
      expect(await pontos.buscarPorId('ponto-1'), isNotNull);
    });

    test('enviarPendentes não baixa os pontos', () async {
      await enfileira(aplicacoes, 's-1');
      postDoLote(api).thenAnswer((_) async => respostaDoLote([criado('s-1')]));

      await criarServico().enviarPendentes();

      verifyNever(() => api.get(any()));
    });

    test(
      'lote misto: aceitos, duplicados e rejeitados e depois o pull',
      () async {
        await enfileira(aplicacoes, 's-1');
        await enfileira(aplicacoes, 's-2', minutos: 1);
        await enfileira(aplicacoes, 's-3', minutos: 2);
        postDoLote(api).thenAnswer(
          (_) async => respostaDoLote([
            criado('s-1'),
            duplicado('s-2'),
            rejeitado('s-3', codigo: 'PONTO_INEXISTENTE'),
          ]),
        );
        pull().thenAnswer((_) async => corpoDoPull([pontoDoPull('ponto-1')]));

        final resultado = await criarServico().sincronizar();

        expect(resultado.concluida, isTrue);
        expect((await item('s-1')).estado, EstadoDoItemDaOutbox.enviado);
        expect((await item('s-2')).estado, EstadoDoItemDaOutbox.enviado);
        expect((await item('s-3')).estado, EstadoDoItemDaOutbox.rejeitado);
        expect(await pontos.buscarPorId('ponto-1'), isNotNull);
      },
    );

    test(
      'sem rede no meio do envio: nada se perde e o pull não roda',
      () async {
        await enfileira(aplicacoes, 's-1');
        await enfileira(aplicacoes, 's-2', minutos: 1);
        postDoLote(api).thenThrow(
          const FalhaDeConexaoException('Tempo esgotado.', tempoEsgotado: true),
        );

        final resultado = await criarServico().sincronizar();

        expect(resultado.concluida, isFalse);
        expect(resultado.envioCompleto, isFalse);
        expect(resultado.pullFalhou, isTrue);
        expect((await item('s-1')).estado, EstadoDoItemDaOutbox.pendente);
        expect((await item('s-2')).estado, EstadoDoItemDaOutbox.pendente);
        verifyNever(() => api.get(any()));
      },
    );

    test(
      'refresh expirado: os itens continuam PENDENTE, a fila não é apagada',
      () async {
        await enfileira(aplicacoes, 's-1');
        postDoLote(api).thenThrow(
          const NaoAutenticadoException('Sua sessão expirou. Entre novamente.'),
        );

        final resultado = await criarServico().sincronizar();

        expect(resultado.concluida, isFalse);
        expect((await item('s-1')).estado, EstadoDoItemDaOutbox.pendente);
        expect(
          (await outbox.contarPorEstado())[EstadoDoItemDaOutbox.pendente],
          1,
        );
        verifyNever(() => api.get(any()));
      },
    );

    test('pull sem rede: o envio fica completo e o banco não muda', () async {
      await pontos.salvar(pontoDeTeste('ponto-1'));
      pull().thenThrow(const FalhaDeConexaoException('Sem conexão.'));

      final resultado = await criarServico().sincronizar();

      expect(resultado.envioCompleto, isTrue);
      expect(resultado.pullFalhou, isTrue);
      expect(resultado.pull, isNull);
      expect(resultado.concluida, isFalse);
      expect(await pontos.buscarPorId('ponto-1'), isNotNull);
    });

    test('resposta ilegível do pull: nada é apagado', () async {
      await pontos.salvar(pontoDeTeste('ponto-1'));
      pull().thenAnswer((_) async => {'pontos': 'não é uma lista'});

      final resultado = await criarServico().sincronizar();

      expect(resultado.pullFalhou, isTrue);
      expect(await pontos.buscarPorId('ponto-1'), isNotNull);
    });

    test('registro feito durante o pull protege o ponto reatribuído', () async {
      await pontos.salvar(pontoDeTeste('ponto-9'));
      pull().thenAnswer((_) async {
        await enfileira(aplicacoes, 's-9', pontoId: 'ponto-9');
        return corpoDoPull([pontoDoPull('ponto-1')]);
      });

      final resultado = await criarServico().sincronizar();

      expect(resultado.pull!.pontosMantidos, ['ponto-9']);
      expect(await pontos.buscarPorId('ponto-9'), isNotNull);
    });

    test('duas sincronizações simultâneas fazem um único pull', () async {
      final liberar = Completer<void>();
      pull().thenAnswer((_) async {
        await liberar.future;
        return corpoDoPull([pontoDoPull('ponto-1')]);
      });
      final servico = criarServico();

      final primeira = servico.sincronizar();
      final segunda = servico.sincronizar();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      liberar.complete();
      final resultados = await Future.wait([primeira, segunda]);

      verify(() => api.get('/sync/pull')).called(1);
      expect(resultados.every((r) => r.concluida), isTrue);
    });

    test(
      'sincronizar durante um envio em curso espera e depois baixa',
      () async {
        await enfileira(aplicacoes, 's-1');
        final liberar = Completer<void>();
        postDoLote(api).thenAnswer((_) async {
          await liberar.future;
          return respostaDoLote([criado('s-1')]);
        });
        pull().thenAnswer((_) async => corpoDoPull([pontoDoPull('ponto-1')]));
        final servico = criarServico();

        final envio = servico.enviarPendentes();
        await Future<void>.delayed(const Duration(milliseconds: 20));
        final sincronizacao = servico.sincronizar();
        liberar.complete();
        await Future.wait([envio, sincronizacao]);

        verify(() => api.get('/sync/pull')).called(1);
        expect(await pontos.buscarPorId('ponto-1'), isNotNull);
      },
    );
  });
}

/// [OutboxDao] que falha ao gravar o resultado do envio (disco cheio, banco
/// bloqueado…) e delega o resto ao DAO real.
class _OutboxQueFalhaAoMarcarEnviado implements OutboxDao {
  _OutboxQueFalhaAoMarcarEnviado(this._real);

  final OutboxDao _real;

  @override
  Future<void> marcarEnviado(Iterable<String> ids) =>
      Future.error(StateError('disco cheio'));

  @override
  Future<ItemDaOutbox?> buscarPorId(String id) => _real.buscarPorId(id);

  @override
  Future<List<ItemDaOutbox>> pendentes({int? limite}) =>
      _real.pendentes(limite: limite);

  @override
  Future<void> marcarEnviando(Iterable<String> ids) =>
      _real.marcarEnviando(ids);

  @override
  Future<void> marcarRejeitado(String id, String motivo) =>
      _real.marcarRejeitado(id, motivo);

  @override
  Future<void> registrarFalha(String id, String erro) =>
      _real.registrarFalha(id, erro);

  @override
  Future<int> reenfileirarEmAndamento() => _real.reenfileirarEmAndamento();

  @override
  Future<Map<EstadoDoItemDaOutbox, int>> contarPorEstado() =>
      _real.contarPorEstado();

  @override
  Future<Set<String>> pontoIdsComPendencias() => _real.pontoIdsComPendencias();
}
