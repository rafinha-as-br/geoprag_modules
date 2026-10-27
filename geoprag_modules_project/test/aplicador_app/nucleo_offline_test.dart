import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/bootstrap.dart';
import 'package:geoprag_modules/aplicador_app/nucleo_offline.dart';
import 'package:geoprag_modules/aplicador_app/sincronizacao/sincronizacao.dart';
import 'package:geoprag_modules/src/api/api_exceptions.dart';
import 'package:geoprag_modules/src/entities/aplicacao.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../support/armazenamento_em_memoria.dart';
import 'sincronizacao/apoio_da_sincronizacao.dart';
import 'sincronizacao/apoio_do_pull.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const bootstrap = AplicadorBootstrap();
  late ApiFalsa api;
  late MonitorFalso monitor;

  Future<NucleoOffline> abrir() {
    sqfliteFfiInit();
    return NucleoOffline.iniciar(
      api: api,
      armazenamento: ArmazenamentoEmMemoria(),
      monitor: monitor,
      fabrica: databaseFactoryFfi,
      caminho: inMemoryDatabasePath,
    );
  }

  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  setUp(() {
    api = ApiFalsa();
    monitor = MonitorFalso();
  });

  tearDown(() async {
    await NucleoOffline.redefinir();
    await monitor.controlador.close();
  });

  test('antes de abrir, pedir as instâncias explica o que falta', () {
    expect(
      () => bootstrap.buildRegistroDeAplicacaoRepository(),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'mensagem',
          contains('iniciarNucleoOffline'),
        ),
      ),
    );
    expect(
      () => bootstrap.buildServicoDeSincronizacao(),
      throwsA(isA<StateError>()),
    );
  });

  test('o bootstrap sempre entrega as mesmas instâncias', () async {
    final nucleo = await abrir();

    expect(
      identical(
        bootstrap.buildRegistroDeAplicacaoRepository(),
        bootstrap.buildRegistroDeAplicacaoRepository(),
      ),
      isTrue,
    );
    expect(
      identical(
        bootstrap.buildServicoDeSincronizacao(),
        bootstrap.buildServicoDeSincronizacao(),
      ),
      isTrue,
    );
    expect(
      identical(bootstrap.buildServicoDeSincronizacao(), nucleo.sincronizacao),
      isTrue,
    );
    expect(
      identical(
        bootstrap.buildRegistroDeAplicacaoRepository(),
        nucleo.registro,
      ),
      isTrue,
    );
  });

  test(
    'abrir de novo devolve o mesmo núcleo, com um único banco e fila',
    () async {
      final primeiro = await abrir();
      final segundo = await abrir();
      final terceiro = await NucleoOffline.iniciar();

      expect(identical(primeiro, segundo), isTrue);
      expect(identical(primeiro, terceiro), isTrue);
      expect(identical(primeiro.banco, segundo.banco), isTrue);
      expect(identical(primeiro.outbox, segundo.outbox), isTrue);
      expect(identical(NucleoOffline.instancia, primeiro), isTrue);
    },
  );

  test('aberturas simultâneas também resultam em um só núcleo', () async {
    final nucleos = await Future.wait([abrir(), abrir()]);

    expect(identical(nucleos.first, nucleos.last), isTrue);
  });

  test('o registro e o serviço abertos compartilham a mesma fila', () async {
    when(() => api.post(any(), corpo: any(named: 'corpo'))).thenAnswer((
      inv,
    ) async {
      final lote = inv.namedArguments[#corpo] as Map<String, dynamic>;
      return respostaDoLote([
        for (final i in lote['itens'] as List<dynamic>)
          criado((i as Map)['id'] as String),
      ]);
    });
    final nucleo = await abrir();
    final aplicacao = await nucleo.registro.iniciarAplicacao(
      pontoId: 'ponto-1',
      aplicadorId: 'aplicador-1',
      dataAgendadaId: 'd-1',
      produtoId: 'produto-1',
      localizacao: _localizacao,
    );

    final atualizada = await nucleo.registro.registrarSubponto(
      aplicacaoId: aplicacao.id,
      latitude: 1,
      longitude: 1,
    );
    await nucleo.sincronizacao.enviarPendentes();

    final item = await nucleo.outbox.buscarPorId(
      atualizada.subpontos.single.id,
    );
    expect(item!.estado.valor, 'ENVIADO');
  });

  test('uma abertura que falha não trava a próxima tentativa', () async {
    sqfliteFfiInit();

    await expectLater(
      NucleoOffline.iniciar(
        api: api,
        armazenamento: ArmazenamentoEmMemoria(),
        monitor: _MonitorQueFalha(),
        fabrica: databaseFactoryFfi,
        caminho: inMemoryDatabasePath,
      ),
      throwsA(isA<StateError>()),
    );
    expect(() => NucleoOffline.instancia, throwsA(isA<StateError>()));

    final nucleo = await abrir();

    expect(identical(NucleoOffline.instancia, nucleo), isTrue);
  });

  test('GEOPRAG-203: depois de uma sincronização, sem rede o aplicador vê o '
      'ponto com o alerta de atraso e registra a aplicação', () async {
    // Data prevista no passado distante: em atraso com qualquer relógio.
    final ponto = pontoDoPull('ponto-1');
    ((ponto['agendamento'] as Map)['datas'] as List).first['data'] =
        '2020-01-01';
    when(
      () => api.get('/sync/pull'),
    ).thenAnswer((_) async => corpoDoPull([ponto]));
    final nucleo = await abrir();
    expect((await nucleo.sincronizacao.sincronizar()).concluida, isTrue);

    // Modo avião.
    const semRede = FalhaDeConexaoException('Sem conexão.');
    when(() => api.get('/sync/pull')).thenThrow(semRede);
    when(() => api.post(any(), corpo: any(named: 'corpo'))).thenThrow(semRede);

    expect(
      [for (final p in await nucleo.pontos.listarMeusPontos('aplicador-1')) p.id],
      ['ponto-1'],
    );
    expect(await nucleo.pontos.idsDePontosEmAtraso('aplicador-1'), {'ponto-1'});
    final produtos = await nucleo.registro.listarProdutos();
    expect(produtos.map((p) => p.id), ['produto-1']);

    final aplicacao = await nucleo.registro.iniciarAplicacao(
      pontoId: 'ponto-1',
      aplicadorId: 'aplicador-1',
      dataAgendadaId: 'ponto-1-d1',
      produtoId: produtos.single.id,
      localizacao: _localizacao,
    );
    for (var i = 0; i < 3; i++) {
      await nucleo.registro.registrarSubponto(
        aplicacaoId: aplicacao.id,
        latitude: -26.9,
        longitude: -48.9,
      );
    }

    expect(await nucleo.pontos.idsDePontosEmAtraso('aplicador-1'), isEmpty);
    expect(
      (await nucleo.pontos.buscarPorId('ponto-1')).subpontos,
      hasLength(3),
    );
    expect(await nucleo.outbox.pontoIdsComPendencias(), {'ponto-1'});
  });

  test('depois de redefinir, o núcleo precisa ser aberto de novo', () async {
    await abrir();
    await NucleoOffline.redefinir();

    expect(() => NucleoOffline.instancia, throwsA(isA<StateError>()));
  });
}

const _localizacao = LocalizacaoCapturada(latitude: -26.9, longitude: -48.9);

/// Monitor que falha ao ser ouvido: faz `GatilhosDeSincronizacao.iniciar`
/// lançar depois de o banco já estar aberto.
class _MonitorQueFalha implements MonitorDeConexao {
  @override
  Stream<void> get aoConectar => throw StateError('plugin indisponível');
}
