import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/distributions/core/distribuicao.dart';
import 'package:geoprag_modules/portal_administrador/distributions/core/distribuicao_repository.dart';
import 'package:geoprag_modules/portal_administrador/distributions/presentation/distribuicoes_cubit.dart';
import 'package:geoprag_modules/portal_administrador/distributions/presentation/distribuicoes_state.dart';
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

  blocTest<DistribuicoesCubit, DistribuicoesState>(
    'emite [Loaded] agregando o nome do produto para cada distribuição',
    setUp: () {
      when(() => repository.listar()).thenAnswer((_) async => [distribuicao]);
      when(() => repository.buscarNomeProduto('p1')).thenAnswer(
        (_) async => 'BTI Líquido - Lote L-001',
      );
    },
    build: () => DistribuicoesCubit(repository),
    expect: () => [
      isA<DistribuicoesLoaded>().having(
        (s) => s.distribuicoes.first.produtoNome,
        'distribuicoes.first.produtoNome',
        'BTI Líquido - Lote L-001',
      ),
    ],
  );

  blocTest<DistribuicoesCubit, DistribuicoesState>(
    'emite [Error] com mensagem amigável quando o repositório falha '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => repository.listar()).thenAnswer((_) async => throw Exception('offline'));
    },
    build: () => DistribuicoesCubit(repository),
    expect: () => [
      isA<DistribuicoesError>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );
}
