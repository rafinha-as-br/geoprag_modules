import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/movimentacao_produto.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/produto.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/produto_repository.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/presentation/produto_detalhe_cubit.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/presentation/visualizacao_produto_screen.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:mocktail/mocktail.dart';

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

  setUp(() {
    repository = MockProdutoRepository();
  });

  Widget wrap(String produtoId) => MaterialApp(
    home: BlocProvider(
      create: (_) => ProdutoDetalheCubit(repository, produtoId),
      child: const VisualizacaoProdutoScreen(),
    ),
  );

  testWidgets('mostra spinner enquanto o produto carrega', (tester) async {
    when(
      () => repository.buscarPorId('p1'),
    ).thenAnswer((_) async => produto);
    when(
      () => repository.buscarMovimentacoes('p1'),
    ).thenAnswer((_) async => const []);

    await tester.pumpWidget(wrap('p1'));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
    'mostra título com nome/lote, cartão centralizado, ações no header '
    'e o aviso de restrição de edição quando o produto carrega',
    (tester) async {
      when(
        () => repository.buscarPorId('p1'),
      ).thenAnswer((_) async => produto);
      when(() => repository.buscarMovimentacoes('p1')).thenAnswer(
        (_) async => const [
          MovimentacaoProduto(
            tipo: MovimentacaoProdutoTipo.saida,
            titulo: 'Saída para Belchior Alto',
            subtitulo: 'Resp: João Silva - 05/07/2026',
            valor: '10 Litros',
          ),
        ],
      );

      // A variante cartão centralizado não tem scroll (mesmo comportamento
      // de antes da migração) — usa um viewport de teste alto o bastante
      // para o conteúdo completo, evitando overflow que só existe por
      // causa do tamanho fixo da janela de teste.
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap('p1'));
      await tester.pumpAndSettle();

      expect(find.text('BTI Líquido - Lote L-001'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      // 2 dividers: o do header do BaseDetailScreen + o que separa o
      // Histórico de Movimentações do restante do conteúdo.
      expect(find.byType(Divider), findsNWidgets(2));
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(
        find.text(
          'Nota: Este produto permite edição apenas em campos '
          'não-críticos e não pode ser excluído.',
        ),
        findsOneWidget,
      );
      expect(find.text('Saída para Belchior Alto'), findsOneWidget);
    },
  );

  testWidgets('mostra mensagem amigável de erro quando o produto não é encontrado', (
    tester,
  ) async {
    when(() => repository.buscarPorId('inexistente')).thenAnswer(
      (_) async => throw const EntidadeNaoEncontradaException(
        'Produto "inexistente" não encontrado.',
      ),
    );

    await tester.pumpWidget(wrap('inexistente'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Não foi possível carregar o produto: '
        'Produto "inexistente" não encontrado.',
      ),
      findsOneWidget,
    );
  });
}
