import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/local/local.dart';

import '../sincronizacao/apoio_da_sincronizacao.dart';
import 'apoio_do_banco.dart';

void main() {
  late BancoLocal banco;
  late AplicacaoDaoSqflite aplicacoes;
  late OutboxDaoSqflite outbox;

  setUp(() async {
    banco = await abrirBancoEmMemoria();
    aplicacoes = AplicacaoDaoSqflite(banco.db);
    outbox = OutboxDaoSqflite(banco.db);
  });

  tearDown(() => banco.fechar());

  group('registrosParaExibir', () {
    test(
      'lista do mais recente para o mais antigo, com o estado de cada um',
      () async {
        await enfileira(aplicacoes, 's-1', minutos: 1);
        await enfileira(aplicacoes, 's-2', minutos: 2);
        await enfileira(aplicacoes, 's-3', minutos: 3);
        await outbox.marcarEnviando(['s-1', 's-2']);
        await outbox.marcarEnviado(['s-1']);
        await outbox.marcarRejeitado('s-2', 'O ponto informado não existe.');

        final registros = await outbox.registrosParaExibir();

        expect(registros.map((r) => r.item.id), ['s-3', 's-2', 's-1']);
        expect(registros.map((r) => r.item.estado), [
          EstadoDoItemDaOutbox.pendente,
          EstadoDoItemDaOutbox.rejeitado,
          EstadoDoItemDaOutbox.enviado,
        ]);
        expect(registros[1].item.ultimoErro, 'O ponto informado não existe.');
      },
    );

    test(
      'traz o nome do ponto; sem o ponto no aparelho, o nome é nulo',
      () async {
        await PontoDaoSqflite(
          banco.db,
        ).salvarTodos([pontoDeTeste('ponto-1', nome: 'Córrego Gasparinho')]);
        await enfileira(aplicacoes, 's-1', pontoId: 'ponto-1', minutos: 1);
        await enfileira(aplicacoes, 's-2', pontoId: 'ponto-sumiu', minutos: 2);

        final registros = await outbox.registrosParaExibir();

        expect(registros[0].item.id, 's-2');
        expect(registros[0].pontoNome, isNull);
        expect(registros[1].item.id, 's-1');
        expect(registros[1].pontoNome, 'Córrego Gasparinho');
      },
    );

    test('limita os enviados aos mais recentes, mas nunca corta pendente nem '
        'rejeitado', () async {
      for (var i = 1; i <= 5; i++) {
        await enfileira(aplicacoes, 'env-$i', minutos: i);
      }
      await enfileira(aplicacoes, 'rej', minutos: 0);
      await enfileira(aplicacoes, 'pen', minutos: 10);
      await outbox.marcarEnviando([for (var i = 1; i <= 5; i++) 'env-$i']);
      await outbox.marcarEnviado([for (var i = 1; i <= 5; i++) 'env-$i']);
      await outbox.marcarEnviando(['rej']);
      await outbox.marcarRejeitado('rej', 'motivo');

      final registros = await outbox.registrosParaExibir(enviadosRecentes: 2);

      expect(registros.map((r) => r.item.id), ['pen', 'env-5', 'env-4', 'rej']);
    });

    test('banco vazio devolve lista vazia', () async {
      expect(await outbox.registrosParaExibir(), isEmpty);
    });
  });
}
