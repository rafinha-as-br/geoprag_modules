import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/distributions/core/distribuicao.dart';
import 'package:geoprag_modules/portal_administrador/distributions/core/distribuicao_repository.dart';
import 'package:geoprag_modules/portal_administrador/distributions/presentation/distribuicao_detalhe_cubit.dart';
import 'package:geoprag_modules/portal_administrador/distributions/presentation/distribuicao_detalhe_state.dart';
import 'package:mocktail/mocktail.dart';

class MockDistribuicaoRepository extends Mock implements DistribuicaoRepository {}

void main() {
  late MockDistribuicaoRepository repository;

  final distribuicao = Distribuicao(
    id: 'd1',
    produtoId: 'p1',
    quantidade: 2,
    unidade: 'Litros',
    dataEntrega: DateTime(2026, 6, 1),
    responsavel: 'João Silva',
    bairroResponsavel: 'Belchior',
    statusConfirmacao: 'confirmado',
  );

  setUp(() {
    repository = MockDistribuicaoRepository();
  });

  blocTest<DistribuicaoDetalheCubit, DistribuicaoDetalheState>(
    'emite [Loaded] com a ficha completa da distribuição do id informado',
    setUp: () {
      when(() => repository.buscarPorId('d1')).thenAnswer((_) async => distribuicao);
      when(() => repository.buscarNomeProduto('p1')).thenAnswer(
        (_) async => 'BTI Líquido - Lote L-001',
      );
    },
    build: () => DistribuicaoDetalheCubit(repository, 'd1'),
    expect: () => [
      isA<DistribuicaoDetalheLoaded>().having(
        (s) => s.distribuicao.produtoNome,
        'distribuicao.produtoNome',
        'BTI Líquido - Lote L-001',
      ),
    ],
    verify: (_) {
      verify(() => repository.buscarPorId('d1')).called(1);
    },
  );

  blocTest<DistribuicaoDetalheCubit, DistribuicaoDetalheState>(
    'emite [Error] com mensagem amigável quando o id não é encontrado '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(
        () => repository.buscarPorId('inexistente'),
      ).thenThrow(StateError('Distribuição "inexistente" não encontrada.'));
    },
    build: () => DistribuicaoDetalheCubit(repository, 'inexistente'),
    expect: () => [
      isA<DistribuicaoDetalheError>().having(
        (s) => s.message,
        'message',
        isNot(contains('StateError')),
      ),
    ],
  );
}
