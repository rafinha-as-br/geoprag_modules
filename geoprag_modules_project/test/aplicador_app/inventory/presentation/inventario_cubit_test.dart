import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/inventory/core/insumo.dart';
import 'package:geoprag_modules/aplicador_app/inventory/core/insumo_repository.dart';
import 'package:geoprag_modules/aplicador_app/inventory/core/recebimento.dart';
import 'package:geoprag_modules/aplicador_app/inventory/core/recebimento_repository.dart';
import 'package:geoprag_modules/aplicador_app/inventory/presentation/inventario_cubit.dart';
import 'package:geoprag_modules/aplicador_app/inventory/presentation/inventario_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geoprag_modules/src/errors/app_error_messages.dart';

class MockInsumoRepository extends Mock implements InsumoRepository {}

class MockRecebimentoRepository extends Mock implements RecebimentoRepository {}

void main() {
  late MockInsumoRepository insumoRepository;
  late MockRecebimentoRepository recebimentoRepository;

  final insumo = Insumo(
    id: '1',
    nome: 'BTI Líquido',
    quantidadeEmEstoque: 950,
    unidadeMedida: 'ml',
    dataUltimaAtualizacao: DateTime.now(),
  );

  final recebimentoPendente = Recebimento(
    id: 'r1',
    produtoNome: 'BTI Líquido',
    quantidadeDescricao: '1 Litro',
    agenteEntregador: 'João Silva',
    cargoAgenteEntregador: 'Fiscal de Agricultura',
    dataDespacho: DateTime(2026, 7, 5),
    status: RecebimentoStatus.pendente,
  );

  setUp(() {
    insumoRepository = MockInsumoRepository();
    recebimentoRepository = MockRecebimentoRepository();
  });

  blocTest<InventarioCubit, InventarioState>(
    'emite [Loaded] com o primeiro insumo e a contagem de pendentes',
    setUp: () {
      when(() => insumoRepository.listar()).thenAnswer((_) async => [insumo]);
      when(
        () => recebimentoRepository.listarPendentes(),
      ).thenAnswer((_) async => [recebimentoPendente]);
    },
    build: () => InventarioCubit(insumoRepository, recebimentoRepository),
    expect: () => [
      isA<InventarioLoaded>()
          .having((s) => s.estoqueAtual.produtoNome, 'produtoNome', 'BTI Líquido')
          .having((s) => s.estoqueAtual.recebimentosPendentesCount, 'pendentes', 1),
    ],
  );

  blocTest<InventarioCubit, InventarioState>(
    'emite [Error] com mensagem amigável quando não há insumos cadastrados '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => insumoRepository.listar()).thenAnswer((_) async => []);
      when(
        () => recebimentoRepository.listarPendentes(),
      ).thenAnswer((_) async => []);
    },
    build: () => InventarioCubit(insumoRepository, recebimentoRepository),
    expect: () => [
      isA<InventarioError>().having(
        (s) => s.message,
        'message',
        'Nenhum insumo cadastrado no inventário.',
      ),
    ],
  );

  blocTest<InventarioCubit, InventarioState>(
    'emite [Error] quando a busca de insumos falha',
    setUp: () {
      when(() => insumoRepository.listar()).thenAnswer((_) async => throw Exception('offline'));
      when(
        () => recebimentoRepository.listarPendentes(),
      ).thenAnswer((_) async => []);
    },
    build: () => InventarioCubit(insumoRepository, recebimentoRepository),
    expect: () => [
      isA<InventarioError>().having(
        (s) => s.message,
        'message',
        AppErrorMessages.carregamentoGenerico,
      ),
    ],
  );
}
