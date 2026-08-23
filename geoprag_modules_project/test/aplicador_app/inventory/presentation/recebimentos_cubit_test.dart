import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/inventory/core/recebimento.dart';
import 'package:geoprag_modules/aplicador_app/inventory/core/recebimento_repository.dart';
import 'package:geoprag_modules/aplicador_app/inventory/presentation/recebimentos_cubit.dart';
import 'package:geoprag_modules/aplicador_app/inventory/presentation/recebimentos_state.dart';
import 'package:mocktail/mocktail.dart';

class MockRecebimentoRepository extends Mock implements RecebimentoRepository {}

void main() {
  late MockRecebimentoRepository repository;

  final pendentes = [
    Recebimento(
      id: 'r1',
      produtoNome: 'BTI Líquido',
      quantidadeDescricao: '1 Litro',
      agenteEntregador: 'João Silva',
      cargoAgenteEntregador: 'Fiscal de Agricultura',
      dataDespacho: DateTime(2026, 7, 5),
      status: RecebimentoStatus.pendente,
    ),
    Recebimento(
      id: 'r2',
      produtoNome: 'BTI Sólido',
      quantidadeDescricao: '500g',
      agenteEntregador: 'João Silva',
      cargoAgenteEntregador: 'Fiscal de Agricultura',
      dataDespacho: DateTime(2026, 7, 3),
      status: RecebimentoStatus.pendente,
    ),
  ];

  setUp(() {
    repository = MockRecebimentoRepository();
  });

  blocTest<RecebimentosCubit, RecebimentosState>(
    'emite [Loaded] com todos os recebimentos pendentes mapeados para ViewModel',
    setUp: () {
      when(() => repository.listarPendentes()).thenAnswer((_) async => pendentes);
    },
    build: () => RecebimentosCubit(repository),
    expect: () => [
      isA<RecebimentosLoaded>().having(
        (s) => s.recebimentos.map((r) => r.id).toList(),
        'ids',
        ['r1', 'r2'],
      ),
    ],
  );

  blocTest<RecebimentosCubit, RecebimentosState>(
    'emite [Loaded] com lista vazia quando não há recebimentos pendentes',
    setUp: () {
      when(() => repository.listarPendentes()).thenAnswer((_) async => []);
    },
    build: () => RecebimentosCubit(repository),
    expect: () => [
      isA<RecebimentosLoaded>().having((s) => s.recebimentos, 'recebimentos', isEmpty),
    ],
  );

  blocTest<RecebimentosCubit, RecebimentosState>(
    'emite [Error] com mensagem amigável quando o repositório falha '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => repository.listarPendentes()).thenAnswer((_) async => throw Exception('offline'));
    },
    build: () => RecebimentosCubit(repository),
    expect: () => [
      isA<RecebimentosError>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );
}
