import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/inventory/core/recebimento.dart';
import 'package:geoprag_modules/aplicador_app/inventory/core/recebimento_repository.dart';
import 'package:geoprag_modules/aplicador_app/inventory/presentation/recebimento_confirmacao_cubit.dart';
import 'package:geoprag_modules/aplicador_app/inventory/presentation/recebimento_confirmacao_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geoprag_modules/src/errors/app_error_messages.dart';

class MockRecebimentoRepository extends Mock implements RecebimentoRepository {}

void main() {
  late MockRecebimentoRepository repository;

  final recebimento = Recebimento(
    id: 'r1',
    produtoNome: 'BTI Líquido',
    lote: 'L-2026-0145',
    quantidadeDescricao: '1 Litro',
    agenteEntregador: 'João Silva',
    cargoAgenteEntregador: 'Fiscal de Agricultura',
    dataDespacho: DateTime(2026, 7, 5),
    status: RecebimentoStatus.pendente,
  );

  setUp(() {
    repository = MockRecebimentoRepository();
  });

  blocTest<RecebimentoConfirmacaoCubit, RecebimentoConfirmacaoState>(
    'com recebimentoId informado, carrega esse recebimento específico via buscarPorId',
    setUp: () {
      when(() => repository.buscarPorId('r1')).thenAnswer((_) async => recebimento);
    },
    build: () => RecebimentoConfirmacaoCubit(repository, recebimentoId: 'r1'),
    expect: () => [
      isA<RecebimentoConfirmacaoLoaded>().having(
        (s) => s.recebimento.id,
        'recebimento.id',
        'r1',
      ),
    ],
    verify: (_) {
      verify(() => repository.buscarPorId('r1')).called(1);
      verifyNever(() => repository.listarPendentes());
    },
  );

  blocTest<RecebimentoConfirmacaoCubit, RecebimentoConfirmacaoState>(
    'sem recebimentoId, carrega o primeiro recebimento pendente da fila',
    setUp: () {
      when(() => repository.listarPendentes()).thenAnswer((_) async => [recebimento]);
    },
    build: () => RecebimentoConfirmacaoCubit(repository),
    expect: () => [
      isA<RecebimentoConfirmacaoLoaded>().having(
        (s) => s.recebimento.id,
        'recebimento.id',
        'r1',
      ),
    ],
  );

  blocTest<RecebimentoConfirmacaoCubit, RecebimentoConfirmacaoState>(
    'sem recebimentoId e sem pendentes, emite [Error] com mensagem amigável '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => repository.listarPendentes()).thenAnswer((_) async => []);
    },
    build: () => RecebimentoConfirmacaoCubit(repository),
    expect: () => [
      isA<RecebimentoConfirmacaoError>().having(
        (s) => s.message,
        'message',
        'Não há recebimentos pendentes de confirmação.',
      ),
    ],
  );

  blocTest<RecebimentoConfirmacaoCubit, RecebimentoConfirmacaoState>(
    'confirmar() delega ao repositório o id do recebimento carregado',
    setUp: () {
      when(() => repository.buscarPorId('r1')).thenAnswer((_) async => recebimento);
      when(() => repository.confirmar('r1')).thenAnswer(
        (_) async => recebimento.copyWith(
          status: RecebimentoStatus.confirmado,
          confirmadoEm: DateTime(2026, 10, 20, 21, 30),
        ),
      );
    },
    build: () => RecebimentoConfirmacaoCubit(repository, recebimentoId: 'r1'),
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      await cubit.confirmar();
    },
    // `confirmar()` não emite novo estado — delega ao repositório e devolve
    // o resultado para a tela dar o feedback.
    expect: () => [isA<RecebimentoConfirmacaoLoaded>()],
    verify: (_) {
      verify(() => repository.confirmar('r1')).called(1);
    },
  );

  test('confirmar() devolve a ViewModel com data/hora da confirmação', () async {
    when(() => repository.buscarPorId('r1')).thenAnswer((_) async => recebimento);
    when(() => repository.confirmar('r1')).thenAnswer(
      (_) async => recebimento.copyWith(
        status: RecebimentoStatus.confirmado,
        confirmadoEm: DateTime(2026, 10, 20, 21, 30),
        registradoEm: DateTime(2026, 10, 20, 21, 30),
      ),
    );
    final cubit = RecebimentoConfirmacaoCubit(repository, recebimentoId: 'r1');
    await Future<void>.delayed(Duration.zero);

    final resultado = await cubit.confirmar();

    expect(resultado!.confirmadoEmDescricao, '20/10/2026 às 21:30');
    expect(resultado.pendenteSincronizacao, isFalse);
  });

  test('confirmar() sinaliza pendência de sincronização quando offline', () async {
    when(() => repository.buscarPorId('r1')).thenAnswer((_) async => recebimento);
    when(() => repository.confirmar('r1')).thenAnswer(
      (_) async => recebimento.copyWith(
        status: RecebimentoStatus.confirmado,
        confirmadoEm: DateTime(2026, 10, 20, 21, 30),
      ),
    );
    final cubit = RecebimentoConfirmacaoCubit(repository, recebimentoId: 'r1');
    await Future<void>.delayed(Duration.zero);

    final resultado = await cubit.confirmar();

    expect(resultado!.pendenteSincronizacao, isTrue);
  });

  blocTest<RecebimentoConfirmacaoCubit, RecebimentoConfirmacaoState>(
    'confirmar() não chama o repositório se o estado atual não for Loaded',
    setUp: () {
      when(() => repository.listarPendentes()).thenAnswer((_) async => []);
    },
    build: () => RecebimentoConfirmacaoCubit(repository),
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      await cubit.confirmar();
    },
    expect: () => [isA<RecebimentoConfirmacaoError>()],
    verify: (_) {
      verifyNever(() => repository.confirmar(any()));
    },
  );

  blocTest<RecebimentoConfirmacaoCubit, RecebimentoConfirmacaoState>(
    'emite [Error] com mensagem genérica (e loga) quando a exceção é '
    'inesperada, sem vazar detalhe técnico',
    setUp: () {
      when(() => repository.listarPendentes()).thenAnswer((_) async => throw Exception('offline'));
    },
    build: () => RecebimentoConfirmacaoCubit(repository),
    expect: () => [
      isA<RecebimentoConfirmacaoError>().having(
        (s) => s.message,
        'message',
        AppErrorMessages.carregamentoGenerico,
      ),
    ],
  );
}
