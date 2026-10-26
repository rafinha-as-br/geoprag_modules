import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/sincronizacao/sincronizacao.dart';
import 'package:geoprag_modules/src/services/gerador_de_id.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/armazenamento_em_memoria.dart';
import 'apoio_da_sincronizacao.dart';

class _ConnectivityFalso extends Mock implements Connectivity {}

void main() {
  group('DispositivoId', () {
    test(
      'gera um UUID na primeira vez e guarda no armazenamento seguro',
      () async {
        final armazenamento = ArmazenamentoEmMemoria();

        final id = await DispositivoId(armazenamento).obter();

        expect(GeradorDeIdUuid.ehUuidV4(id), isTrue);
        expect(armazenamento.dados.values, [id]);
      },
    );

    test(
      'a mesma instância devolve sempre o mesmo valor, gravando uma vez',
      () async {
        final armazenamento = ArmazenamentoEmMemoria();
        final dispositivo = DispositivoId(
          armazenamento,
          gerador: GeradorSequencial(),
        );

        final primeiro = await dispositivo.obter();
        final segundo = await dispositivo.obter();

        expect(primeiro, 'id-1');
        expect(segundo, 'id-1');
      },
    );

    test('chamadas simultâneas não geram dois ids', () async {
      final dispositivo = DispositivoId(
        ArmazenamentoEmMemoria(),
        gerador: GeradorSequencial(),
      );

      final ids = await Future.wait([dispositivo.obter(), dispositivo.obter()]);

      expect(ids, ['id-1', 'id-1']);
    });

    test('reabrir o app (instância nova) lê o mesmo id', () async {
      final armazenamento = ArmazenamentoEmMemoria();
      final antes = await DispositivoId(armazenamento).obter();

      final depois = await DispositivoId(armazenamento).obter();

      expect(depois, antes);
    });

    test('valor vazio guardado é substituído por um id novo', () async {
      final armazenamento = ArmazenamentoEmMemoria();
      await DispositivoId(armazenamento).obter();
      final chave = armazenamento.dados.keys.single;
      armazenamento.dados[chave] = '';

      final id = await DispositivoId(
        armazenamento,
        gerador: GeradorSequencial(),
      ).obter();

      expect(id, 'id-1');
      expect(armazenamento.dados[chave], 'id-1');
    });
  });

  group('MonitorDeConexaoConnectivity', () {
    test(
      'emite quando há alguma rede, inclusive na troca de uma por outra',
      () async {
        final connectivity = _ConnectivityFalso();
        when(() => connectivity.onConnectivityChanged).thenAnswer(
          (_) => Stream.fromIterable([
            [ConnectivityResult.none],
            [ConnectivityResult.wifi],
            [ConnectivityResult.mobile],
            [ConnectivityResult.none],
            [ConnectivityResult.none, ConnectivityResult.vpn],
          ]),
        );

        final eventos = await MonitorDeConexaoConnectivity(
          connectivity,
        ).aoConectar.toList();

        expect(eventos, hasLength(3));
      },
    );
  });
}
