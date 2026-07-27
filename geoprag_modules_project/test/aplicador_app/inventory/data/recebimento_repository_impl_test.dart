import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/inventory/core/recebimento.dart';
import 'package:geoprag_modules/aplicador_app/inventory/data/mock_recebimentos.dart';
import 'package:geoprag_modules/aplicador_app/inventory/data/recebimento_repository_impl.dart';

// NOTA: `RecebimentoRepositoryImpl.confirmar` muta a lista `mockRecebimentos`
// (estado global em memória, compartilhado entre instâncias do repositório).
// Os testes abaixo restauram o status original em `tearDown` para não
// vazar estado entre casos de teste.
void main() {
  late RecebimentoRepositoryImpl repository;

  setUp(() {
    repository = RecebimentoRepositoryImpl();
  });

  tearDown(() {
    for (var i = 0; i < mockRecebimentos.length; i++) {
      mockRecebimentos[i] = mockRecebimentos[i].copyWith(
        status: RecebimentoStatus.pendente,
      );
    }
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

  test('buscarPorId lança StateError quando o id não existe', () {
    expect(
      () => repository.buscarPorId('inexistente'),
      throwsA(isA<StateError>()),
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

  test('confirmar lança StateError quando o id não existe', () {
    expect(
      () => repository.confirmar('inexistente'),
      throwsA(isA<StateError>()),
    );
  });
}
