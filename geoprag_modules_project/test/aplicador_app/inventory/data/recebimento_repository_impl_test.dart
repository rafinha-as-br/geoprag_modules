import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/inventory/core/recebimento.dart';
import 'package:geoprag_modules/aplicador_app/inventory/data/mock_recebimentos.dart';
import 'package:geoprag_modules/aplicador_app/inventory/data/recebimento_repository_impl.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';

// NOTA: `RecebimentoRepositoryImpl.confirmar` muta a lista `mockRecebimentos`
// (estado global em memória, compartilhado entre instâncias do repositório).
// Os testes abaixo restauram a lista original em `tearDown` para não vazar
// estado entre casos de teste.
void main() {
  late RecebimentoRepositoryImpl repository;
  late List<Recebimento> original;

  setUp(() {
    repository = RecebimentoRepositoryImpl();
    original = List.of(mockRecebimentos);
  });

  tearDown(() {
    mockRecebimentos
      ..clear()
      ..addAll(original);
    mockRecebimentosOnline = true;
  });

  test('listarPendentes retorna apenas recebimentos com status pendente', () async {
    final result = await repository.listarPendentes();

    expect(result, isNotEmpty);
    expect(result.every((r) => r.status == RecebimentoStatus.pendente), isTrue);
  });

  test('buscarPorId retorna o recebimento correspondente', () async {
    final result = await repository.buscarPorId('r1');

    expect(result.id, 'r1');
    expect(result.produtoNome, 'BTI Líquido');
  });

  test('buscarPorId lança EntidadeNaoEncontradaException quando o id não existe', () {
    expect(
      () => repository.buscarPorId('inexistente'),
      throwsA(isA<EntidadeNaoEncontradaException>()),
    );
  });

  test('confirmar muda o status do recebimento para confirmado', () async {
    await repository.confirmar('r1');

    final atualizado = await repository.buscarPorId('r1');
    expect(atualizado.status, RecebimentoStatus.confirmado);
  });

  test('confirmar remove o recebimento da listagem de pendentes', () async {
    final antesCount = (await repository.listarPendentes()).length;

    await repository.confirmar('r1');

    final depois = await repository.listarPendentes();
    expect(depois.length, antesCount - 1);
    expect(depois.any((r) => r.id == 'r1'), isFalse);
  });

  test('confirmar lança EntidadeNaoEncontradaException quando o id não existe', () {
    expect(
      () => repository.confirmar('inexistente'),
      throwsA(isA<EntidadeNaoEncontradaException>()),
    );
  });

  test('confirmar online registra ocorrência e registro na mesma hora', () async {
    final confirmado = await repository.confirmar('r1');

    expect(confirmado.confirmadoEm, isNotNull);
    expect(confirmado.registradoEm, isNotNull);
    expect(confirmado.pendenteSincronizacao, isFalse);
  });

  test('confirmar offline guarda a ocorrência e deixa o registro pendente', () async {
    mockRecebimentosOnline = false;
    final ocorrencia = DateTime.now().subtract(const Duration(hours: 2));

    final confirmado = await repository.confirmar(
      'r1',
      confirmadoEm: ocorrencia,
    );

    expect(confirmado.status, RecebimentoStatus.confirmado);
    expect(confirmado.confirmadoEm, ocorrencia);
    expect(confirmado.registradoEm, isNull);
    expect(confirmado.pendenteSincronizacao, isTrue);
  });

  test('sincronizarPendentes registra confirmações offline com data posterior à ocorrência', () async {
    mockRecebimentosOnline = false;
    final ocorrencia = DateTime.now().subtract(const Duration(hours: 2));
    await repository.confirmar('r1', confirmadoEm: ocorrencia);

    mockRecebimentosOnline = true;
    final sincronizados = await repository.sincronizarPendentes();

    expect(sincronizados.map((r) => r.id), ['r1']);
    expect(sincronizados.single.confirmadoEm, ocorrencia);
    expect(sincronizados.single.registradoEm!.isAfter(ocorrencia), isTrue);
    expect(sincronizados.single.pendenteSincronizacao, isFalse);
  });

  test('confirmar duas vezes preserva a ocorrência original', () async {
    final primeira = await repository.confirmar('r1');
    final segunda = await repository.confirmar(
      'r1',
      confirmadoEm: DateTime(2030),
    );

    expect(segunda.confirmadoEm, primeira.confirmadoEm);
  });

  test('sincronizarPendentes não faz nada sem conexão', () async {
    mockRecebimentosOnline = false;
    await repository.confirmar('r1');

    expect(await repository.sincronizarPendentes(), isEmpty);
    expect((await repository.buscarPorId('r1')).pendenteSincronizacao, isTrue);
  });
}
