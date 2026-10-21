import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/local/local.dart';
import 'package:geoprag_modules/aplicador_app/sincronizacao/sincronizacao.dart';
import 'package:geoprag_modules/src/api/api_exceptions.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/armazenamento_em_memoria.dart';
import '../local/apoio_do_banco.dart';
import 'apoio_da_sincronizacao.dart';
import 'apoio_do_pull.dart';

void main() {
  late BancoLocal banco;
  late AplicacaoDaoSqflite aplicacoes;
  late OutboxDaoSqflite outbox;
  late ApiFalsa api;
  late ArmazenamentoEmMemoria armazenamento;
  late ServicoDeSincronizacaoAcompanhado servico;
  late PainelDeSincronizacaoImpl painel;
  var relogio = DateTime.utc(2026, 10, 21, 12);

  ServicoDeSincronizacaoAcompanhado criarServico() =>
      ServicoDeSincronizacaoAcompanhado(
        ServicoDeSincronizacaoImpl(
          api: api,
          outbox: outbox,
          reconciliador: reconciliadorDe(banco),
          dispositivoId: () async => 'aparelho-1',
        ),
        UltimaSincronizacao(armazenamento),
        agora: () => relogio,
      );

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() async {
    banco = await abrirBancoEmMemoria();
    aplicacoes = AplicacaoDaoSqflite(banco.db);
    outbox = OutboxDaoSqflite(banco.db);
    api = ApiFalsa();
    armazenamento = ArmazenamentoEmMemoria();
    relogio = DateTime.utc(2026, 10, 21, 12);
    servico = criarServico();
    painel = PainelDeSincronizacaoImpl(registros: outbox, servico: servico);
    when(
      () => api.get('/sync/pull'),
    ).thenAnswer((_) async => corpoDoPull(const []));
  });

  tearDown(() => banco.fechar());

  group('registro offline e reconexão', () {
    test('offline o registro fica pendente; ao sincronizar passa a enviado sem '
        'ação do usuário e a data da última sincronização aparece', () async {
      await enfileira(aplicacoes, 's-1');
      postDoLote(api).thenThrow(const FalhaDeConexaoException('sem rede'));

      await servico.sincronizar();
      var situacao = await painel.carregar();

      expect(situacao.pendentes, 1);
      expect(situacao.registros.single.situacao, SituacaoDoRegistro.pendente);
      expect(situacao.registros.single.motivo, isNull);
      expect(situacao.ultimaSincronizacao, isNull);

      postDoLote(api).thenAnswer((_) async => respostaDoLote([criado('s-1')]));
      await servico.sincronizar();
      situacao = await painel.carregar();

      expect(situacao.pendentes, 0);
      expect(situacao.registros.single.situacao, SituacaoDoRegistro.enviado);
      expect(situacao.ultimaSincronizacao, relogio.toLocal());
    });

    test(
      'o horário da última sincronização sobrevive ao fechamento do app',
      () async {
        await enfileira(aplicacoes, 's-1');
        postDoLote(
          api,
        ).thenAnswer((_) async => respostaDoLote([criado('s-1')]));
        await servico.sincronizar();

        final reaberto = criarServico();

        expect(await reaberto.ultimaBemSucedida(), relogio.toLocal());
      },
    );

    test('sincronização que não se completa não muda o horário', () async {
      await enfileira(aplicacoes, 's-1');
      postDoLote(api).thenAnswer((_) async => respostaDoLote([criado('s-1')]));
      await servico.sincronizar();
      final primeira = await servico.ultimaBemSucedida();

      relogio = relogio.add(const Duration(hours: 1));
      await enfileira(aplicacoes, 's-2', minutos: 1);
      postDoLote(api).thenThrow(const FalhaDeConexaoException('sem rede'));
      await servico.sincronizar();

      expect(await servico.ultimaBemSucedida(), primeira);
    });

    test('só enviar pendentes não conta como sincronização completa', () async {
      await enfileira(aplicacoes, 's-1');
      postDoLote(api).thenAnswer((_) async => respostaDoLote([criado('s-1')]));

      await servico.enviarPendentes();

      expect(await servico.ultimaBemSucedida(), isNull);
    });
  });

  group('registro rejeitado', () {
    test('mostra o motivo legível e nunca volta à fila', () async {
      await enfileira(aplicacoes, 's-1');
      postDoLote(api).thenAnswer(
        (_) async => respostaDoLote([
          rejeitado(
            's-1',
            codigo: 'PONTO_INEXISTENTE',
            motivo: 'O ponto informado não existe para o tenant.',
          ),
        ]),
      );

      await servico.sincronizar();
      await servico.sincronizar();
      final registro = (await painel.carregar()).registros.single;

      expect(registro.situacao, SituacaoDoRegistro.rejeitado);
      expect(registro.motivo, 'O ponto informado não existe.');
      verify(
        () => api.post('/sync/aplicacoes', corpo: any(named: 'corpo')),
      ).called(1);
      expect((await painel.carregar()).pendentes, 0);
    });

    test('rejeição sem texto vira o motivo genérico', () async {
      await enfileira(aplicacoes, 's-1');
      postDoLote(api).thenAnswer(
        (_) async =>
            respostaDoLote([rejeitado('s-1', codigo: 'DADOS_INVALIDOS')]),
      );

      await servico.sincronizar();

      expect(
        (await painel.carregar()).registros.single.motivo,
        'Registro recusado pelo servidor.',
      );
    });
  });

  group('conflito no servidor', () {
    test(
      'registro aceito aparece como enviado, sem aviso de conflito',
      () async {
        await enfileira(aplicacoes, 's-1');
        // O servidor aceita e marca o conflito só do lado dele: a resposta do
        // lote é igual à de um registro sem conflito.
        postDoLote(
          api,
        ).thenAnswer((_) async => respostaDoLote([criado('s-1')]));

        await servico.sincronizar();
        final registro = (await painel.carregar()).registros.single;

        expect(registro.situacao, SituacaoDoRegistro.enviado);
        expect(registro.motivo, isNull);
      },
    );
  });

  group('aoMudar', () {
    test('avisa quando uma sincronização ou um envio termina', () async {
      var avisos = 0;
      final assinatura = painel.aoMudar.listen((_) => avisos++);
      postDoLote(api).thenAnswer((_) async => respostaDoLote(const []));

      await servico.sincronizar();
      await servico.enviarPendentes();
      await Future<void>.delayed(Duration.zero);

      expect(avisos, 2);
      await assinatura.cancel();
    });

    test('avisa mesmo quando a sincronização falha por dentro', () async {
      var avisos = 0;
      final assinatura = painel.aoMudar.listen((_) => avisos++);
      await enfileira(aplicacoes, 's-1');
      postDoLote(api).thenThrow(const FalhaDeConexaoException('sem rede'));

      await servico.sincronizar();
      await Future<void>.delayed(Duration.zero);

      expect(avisos, 1);
      await assinatura.cancel();
    });
  });

  group('sincronizarAgora', () {
    test('devolve true quando tudo foi enviado e baixado', () async {
      await enfileira(aplicacoes, 's-1');
      postDoLote(api).thenAnswer((_) async => respostaDoLote([criado('s-1')]));

      expect(await painel.sincronizarAgora(), isTrue);
    });

    test('devolve false sem rede, e o registro continua guardado', () async {
      await enfileira(aplicacoes, 's-1');
      postDoLote(api).thenThrow(const FalhaDeConexaoException('sem rede'));

      expect(await painel.sincronizarAgora(), isFalse);
      expect((await painel.carregar()).pendentes, 1);
    });
  });

  group('UltimaSincronizacao', () {
    test('valor ilegível guardado vale como nunca sincronizado', () async {
      armazenamento.dados['geoprag.sincronizacao.ultima_bem_sucedida'] = 'lixo';

      expect(await UltimaSincronizacao(armazenamento).ler(), isNull);
    });

    test('falha ao guardar o horário não derruba a sincronização', () async {
      final falso = ServicoFalso();
      when(
        falso.sincronizar,
      ).thenAnswer((_) async => const ResultadoDaSincronizacao());
      final servicoComFalha = ServicoDeSincronizacaoAcompanhado(
        falso,
        UltimaSincronizacao(_ArmazenamentoQueFalha()),
      );

      final resultado = await servicoComFalha.sincronizar();

      expect(resultado.concluida, isTrue);
    });
  });

  group('motivoLegivelDaRejeicao', () {
    test('mantém o texto do servidor', () {
      expect(
        motivoLegivelDaRejeicao('Os dados do registro são inválidos.'),
        'Os dados do registro são inválidos.',
      );
    });

    test('código ou vazio viram o texto genérico', () {
      for (final bruto in [
        null,
        '',
        '  ',
        'DADOS_INVALIDOS',
        'dados_invalidos',
      ]) {
        expect(
          motivoLegivelDaRejeicao(bruto),
          'Registro recusado pelo servidor.',
        );
      }
    });
  });
}

class _ArmazenamentoQueFalha extends ArmazenamentoEmMemoria {
  @override
  Future<void> gravar(String chave, String valor) =>
      Future.error(StateError('armazenamento indisponível'));
}
