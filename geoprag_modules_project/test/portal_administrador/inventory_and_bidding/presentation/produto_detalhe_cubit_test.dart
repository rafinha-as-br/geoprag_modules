import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/movimentacao_produto.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/produto.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/produto_repository.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/presentation/produto_detalhe_cubit.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/presentation/produto_detalhe_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:geoprag_modules/src/errors/app_error_messages.dart';

class MockProdutoRepository extends Mock implements ProdutoRepository {}

void main() {
  late MockProdutoRepository repository;

  final produto = Produto(
    id: 'p1',
    nome: 'BTI Líquido',
    lote: 'L-001',
    dataValidade: DateTime(2026, 12, 1),
    status: 'Produto em estoque',
    quantidade: 50,
    quantidadeOriginal: 1000,
    unidadeMedida: 'Litros',
    licitacao: 'Pregão 01/2026',
    fornecedor: 'BioInsumos Ltda.',
  );

  const movimentacao = MovimentacaoProduto(
    tipo: MovimentacaoProdutoTipo.saida,
    titulo: 'Saída para Belchior Alto',
    subtitulo: 'Resp: João Silva - 05/07/2026',
    valor: '10 Litros',
  );

  setUp(() {
    repository = MockProdutoRepository();
  });

  blocTest<ProdutoDetalheCubit, ProdutoDetalheState>(
    'emite [Loaded] com o produto e as movimentações do id informado',
    setUp: () {
      when(() => repository.buscarPorId('p1')).thenAnswer((_) async => produto);
      when(
        () => repository.buscarMovimentacoes('p1'),
      ).thenAnswer((_) async => [movimentacao]);
    },
    build: () => ProdutoDetalheCubit(repository, 'p1'),
    expect: () => [
      isA<ProdutoDetalheLoaded>()
          .having((s) => s.produto.nome, 'produto.nome', 'BTI Líquido')
          .having((s) => s.produto.movimentacoes, 'produto.movimentacoes', hasLength(1)),
    ],
  );

  blocTest<ProdutoDetalheCubit, ProdutoDetalheState>(
    'emite [Error] com mensagem amigável quando o id não é encontrado '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(
        () => repository.buscarPorId('inexistente'),
      ).thenThrow(const EntidadeNaoEncontradaException('Produto "inexistente" não encontrado.'));
    },
    build: () => ProdutoDetalheCubit(repository, 'inexistente'),
    expect: () => [
      isA<ProdutoDetalheError>().having(
        (s) => s.message,
        'message',
        'Produto "inexistente" não encontrado.',
      ),
    ],
  );

  blocTest<ProdutoDetalheCubit, ProdutoDetalheState>(
    'emite [Error] com mensagem genérica (e loga) quando a exceção é '
    'inesperada, sem vazar detalhe técnico',
    setUp: () {
      when(() => repository.buscarPorId('inexistente')).thenThrow(Exception('offline'));
    },
    build: () => ProdutoDetalheCubit(repository, 'inexistente'),
    expect: () => [
      isA<ProdutoDetalheError>().having(
        (s) => s.message,
        'message',
        AppErrorMessages.carregamentoGenerico,
      ),
    ],
  );
}
