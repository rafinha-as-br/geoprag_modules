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
      when(() => repository.confirmar('r1')).thenAnswer((_) async {});
    },
    build: () => RecebimentoConfirmacaoCubit(repository, recebimentoId: 'r1'),
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      await cubit.confirmar();
    },
    // `confirmar()` não emite nenhum novo estado hoje — só delega ao
    // repositório (ver TODO no cubit sobre feedback de sucesso).
    expect: () => [isA<RecebimentoConfirmacaoLoaded>()],
    verify: (_) {
      verify(() => repository.confirmar('r1')).called(1);
    },
  );

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
      when(() => repository.listarPendentes()).thenThrow(Exception('offline'));
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
