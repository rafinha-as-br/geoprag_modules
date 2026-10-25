import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/local/local.dart';

import 'apoio_do_banco.dart';

void main() {
  Future<List<String>> tabelas(BancoLocal banco) async {
    final linhas = await banco.db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite_%' ORDER BY name",
    );
    return [for (final l in linhas) l['name']! as String];
  }

  group('esquema', () {
    test(
      'banco novo tem pontos, datas, aplicações, subpontos e outbox',
      () async {
        final banco = await abrirBancoEmMemoria();
        addTearDown(banco.fechar);

        expect(await tabelas(banco), [
          'aplicacoes',
          'datas_agendadas',
          'outbox',
          'pontos',
          'produtos',
          'subpontos',
        ]);
      },
    );

    test('guarda a versão do esquema', () async {
      final banco = await abrirBancoEmMemoria();
      addTearDown(banco.fechar);

      expect(await versaoDoBanco(banco.db), migracoesDoEsquema.last.versao);
    });

    test('as chaves estrangeiras estão ligadas', () async {
      final banco = await abrirBancoEmMemoria();
      addTearDown(banco.fechar);

      final linhas = await banco.db.rawQuery('PRAGMA foreign_keys');
      expect(linhas.single['foreign_keys'], 1);
    });

    test('as versões das migrações são crescentes e começam em 1', () {
      final versoes = [for (final m in migracoesDoEsquema) m.versao];
      expect(versoes.first, 1);
      for (var i = 1; i < versoes.length; i++) {
        expect(versoes[i], versoes[i - 1] + 1);
      }
    });
  });

  group('migração de esquema', () {
    // Uma migração hipotética depois da última real, para provar o mecanismo.
    final proxima = migracoesDoEsquema.last.versao + 1;
    final v2 = Migracao(proxima, [
      'ALTER TABLE outbox ADD COLUMN prioridade INTEGER NOT NULL DEFAULT 0',
      'CREATE TABLE extras (id TEXT PRIMARY KEY, nome TEXT NOT NULL)',
    ]);

    test('banco existente roda só a migração nova e mantém os dados', () async {
      final arquivo = await arquivoTemporarioDeBanco();
      addTearDown(() => arquivo.pasta.delete(recursive: true));

      final antes = await abrirBancoEmArquivo(arquivo.caminho);
      final aplicacao = aplicacaoDeTeste(
        'app-1',
        subpontos: [subpontoDeTeste('s-1')],
      );
      await AplicacaoDaoSqflite(antes.db).gravarComOutbox(aplicacao, [
        itemDoSubponto(aplicacao, aplicacao.subpontos.single),
      ]);
      await antes.fechar();

      final depois = await abrirBancoEmArquivo(
        arquivo.caminho,
        migracoes: [...migracoesDoEsquema, v2],
      );
      addTearDown(depois.fechar);

      expect(await versaoDoBanco(depois.db), proxima);
      expect(await tabelas(depois), contains('extras'));
      final item = await depois.db.query('outbox');
      expect(item.single['id'], 's-1');
      expect(item.single['prioridade'], 0);
      expect(
        await AplicacaoDaoSqflite(depois.db).buscarPorId('app-1'),
        isNotNull,
      );
    });

    test('banco novo roda todas as migrações em ordem', () async {
      final banco = await abrirBancoEmMemoria(
        migracoes: [...migracoesDoEsquema, v2],
      );
      addTearDown(banco.fechar);

      expect(await versaoDoBanco(banco.db), proxima);
      expect(await tabelas(banco), containsAll(['outbox', 'extras']));
    });

    test('reabrir na mesma versão não repete migração', () async {
      final arquivo = await arquivoTemporarioDeBanco();
      addTearDown(() => arquivo.pasta.delete(recursive: true));

      final primeira = await abrirBancoEmArquivo(arquivo.caminho);
      await primeira.fechar();

      // Se a migração 1 rodasse de novo, o CREATE TABLE falharia.
      final segunda = await abrirBancoEmArquivo(arquivo.caminho);
      addTearDown(segunda.fechar);
      expect(await versaoDoBanco(segunda.db), migracoesDoEsquema.last.versao);
    });
  });

  test('os dados sobrevivem ao fechamento do banco', () async {
    final arquivo = await arquivoTemporarioDeBanco();
    addTearDown(() => arquivo.pasta.delete(recursive: true));

    final antes = await abrirBancoEmArquivo(arquivo.caminho);
    await PontoDaoSqflite(antes.db).salvar(pontoDeTeste('ponto-1'));
    await antes.fechar();
    expect(File(arquivo.caminho).existsSync(), isTrue);

    final depois = await abrirBancoEmArquivo(arquivo.caminho);
    addTearDown(depois.fechar);
    final ponto = await PontoDaoSqflite(depois.db).buscarPorId('ponto-1');
    expect(ponto?.nome, 'Córrego Gasparinho');
  });
}
