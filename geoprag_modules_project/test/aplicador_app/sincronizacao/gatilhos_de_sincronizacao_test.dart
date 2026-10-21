import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/local/local.dart';
import 'package:geoprag_modules/aplicador_app/sincronizacao/sincronizacao.dart';
import 'package:geoprag_modules/src/api/api_exceptions.dart';
import 'package:mocktail/mocktail.dart';

import '../local/apoio_do_banco.dart';
import 'apoio_da_sincronizacao.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BancoLocal banco;
  late AplicacaoDaoSqflite aplicacoes;
  late OutboxDaoSqflite outbox;
  late MonitorFalso monitor;
  late ServicoFalso servico;
  late GatilhosDeSincronizacao gatilhos;

  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  setUp(() async {
    banco = await abrirBancoEmMemoria();
    aplicacoes = AplicacaoDaoSqflite(banco.db);
    outbox = OutboxDaoSqflite(banco.db);
    monitor = MonitorFalso();
    servico = ServicoFalso();
    when(() => servico.enviarPendentes()).thenAnswer((_) async {});
    gatilhos = GatilhosDeSincronizacao(
      servico: servico,
      outbox: outbox,
      monitor: monitor,
    );
  });

  tearDown(() async {
    await gatilhos.parar();
    await monitor.controlador.close();
    await banco.fechar();
  });

  /// Deixa os eventos do stream chegarem aos ouvintes.
  Future<void> esperar() => Future<void>.delayed(Duration.zero);

  test('ao abrir o app, tenta enviar o que ficou pendente', () async {
    await gatilhos.iniciar();

    verify(() => servico.enviarPendentes()).called(1);
  });

  test('ao abrir, devolve à fila o item que ficou ENVIANDO', () async {
    await enfileira(aplicacoes, 's-1');
    await outbox.marcarEnviando(['s-1']);

    await gatilhos.iniciar();

    expect(
      (await outbox.buscarPorId('s-1'))!.estado,
      EstadoDoItemDaOutbox.pendente,
    );
  });

  test('ao recuperar a conexão, tenta enviar de novo', () async {
    await gatilhos.iniciar();
    clearInteractions(servico);

    monitor.conectar();
    await esperar();

    verify(() => servico.enviarPendentes()).called(1);
  });

  test(
    'ao voltar ao primeiro plano, tenta enviar; ao ir para o fundo, não',
    () async {
      await gatilhos.iniciar();
      clearInteractions(servico);

      gatilhos.didChangeAppLifecycleState(AppLifecycleState.paused);
      verifyNever(() => servico.enviarPendentes());

      gatilhos.didChangeAppLifecycleState(AppLifecycleState.resumed);
      verify(() => servico.enviarPendentes()).called(1);
    },
  );

  test('iniciar de novo não duplica os gatilhos', () async {
    await gatilhos.iniciar();
    await gatilhos.iniciar();
    clearInteractions(servico);

    monitor.conectar();
    await esperar();

    verify(() => servico.enviarPendentes()).called(1);
  });

  test('depois de parar, nada mais dispara', () async {
    await gatilhos.iniciar();
    await gatilhos.parar();
    clearInteractions(servico);

    monitor.conectar();
    await esperar();

    verifyNever(() => servico.enviarPendentes());
  });

  test(
    'só passa a ouvir a rede depois de reenfileirar o que estava ENVIANDO',
    () async {
      final reenfileirando = Completer<int>();
      final lenta = _OutboxLenta(outbox, reenfileirando.future);
      final comOutboxLenta = GatilhosDeSincronizacao(
        servico: servico,
        outbox: lenta,
        monitor: monitor,
      );

      final iniciando = comOutboxLenta.iniciar();
      monitor.conectar(); // ninguém ouve ainda: o reenfileiramento não concorre
      await esperar();
      verifyNever(() => servico.enviarPendentes());

      reenfileirando.complete(0);
      await iniciando;

      verify(() => servico.enviarPendentes()).called(1);
      await comOutboxLenta.parar();
    },
  );

  test('falha do envio nunca derruba o gatilho', () async {
    when(() => servico.enviarPendentes()).thenThrow(StateError('boom'));

    await gatilhos.iniciar();
    monitor.conectar();
    await esperar();

    // Abrir e reconectar tentaram enviar; nenhum erro escapou.
    verify(() => servico.enviarPendentes()).called(2);
  });

  test(
    'conexão reportada mas servidor inalcançável: o registro não se perde',
    () async {
      final api = ApiFalsa();
      postDoLote(api).thenThrow(const FalhaDeConexaoException('Sem conexão.'));
      final real = ServicoDeSincronizacaoImpl(
        api: api,
        outbox: outbox,
        dispositivoId: () async => 'aparelho-1',
      );
      await enfileira(aplicacoes, 's-1');
      final comServicoReal = GatilhosDeSincronizacao(
        servico: real,
        outbox: outbox,
        monitor: monitor,
      );

      await comServicoReal.iniciar(); // o monitor diz "conectado", a API não
      monitor.conectar();
      await real.enviarPendentes();
      await comServicoReal.parar();

      final item = (await outbox.buscarPorId('s-1'))!;
      expect(item.estado, EstadoDoItemDaOutbox.pendente);
      expect(item.tentativas, greaterThanOrEqualTo(1));
    },
  );
}

/// [OutboxDao] cujo reenfileiramento só termina quando o teste manda.
class _OutboxLenta implements OutboxDao {
  _OutboxLenta(this._real, this._reenfileirando);

  final OutboxDao _real;
  final Future<int> _reenfileirando;

  @override
  Future<int> reenfileirarEmAndamento() => _reenfileirando;

  @override
  Future<ItemDaOutbox?> buscarPorId(String id) => _real.buscarPorId(id);

  @override
  Future<List<ItemDaOutbox>> pendentes({int? limite}) =>
      _real.pendentes(limite: limite);

  @override
  Future<void> marcarEnviando(Iterable<String> ids) =>
      _real.marcarEnviando(ids);

  @override
  Future<void> marcarEnviado(Iterable<String> ids) => _real.marcarEnviado(ids);

  @override
  Future<void> marcarRejeitado(String id, String motivo) =>
      _real.marcarRejeitado(id, motivo);

  @override
  Future<void> registrarFalha(String id, String erro) =>
      _real.registrarFalha(id, erro);

  @override
  Future<Map<EstadoDoItemDaOutbox, int>> contarPorEstado() =>
      _real.contarPorEstado();

  @override
  Future<Set<String>> pontoIdsComPendencias() => _real.pontoIdsComPendencias();
}
