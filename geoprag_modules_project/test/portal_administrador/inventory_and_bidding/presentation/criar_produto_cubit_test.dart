import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/licitacao.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/licitacao_repository.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/produto.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/produto_repository.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/presentation/criar_produto_cubit.dart';
import 'package:geoprag_modules/src/widgets/base_form_screen.dart';
import 'package:geoprag_modules/src/widgets/geoprag_data_nascimento_input.dart';
import 'package:mocktail/mocktail.dart';

class MockProdutoRepository extends Mock implements ProdutoRepository {}

class MockLicitacaoRepository extends Mock implements LicitacaoRepository {}

void main() {
  late MockProdutoRepository produtoRepository;
  late MockLicitacaoRepository licitacaoRepository;
  late CriarProdutoCubit cubit;

  Widget wrap() => MaterialApp(
    home: Scaffold(
      body: BlocProvider<CriarProdutoCubit>.value(
        value: cubit,
        child: const BaseFormScreen<CriarProdutoCubit>(),
      ),
    ),
  );

  setUp(() {
    produtoRepository = MockProdutoRepository();
    licitacaoRepository = MockLicitacaoRepository();
  });

  Future<void> criarCubitCarregado(WidgetTester tester) async {
    when(
      () => licitacaoRepository.listar(),
    ).thenAnswer(
      (_) async => [
        Licitacao(
          id: 'l1',
          numeroAno: 'Pregão 01/2026',
          fornecedorVencedor: 'BioInsumos Ltda.',
          objetoLicitado: 'Aquisição de BTI',
          valorTotal: 85000,
          dataHomologacao: DateTime(2026, 1, 20),
        ),
      ],
    );
    cubit = CriarProdutoCubit(produtoRepository, licitacaoRepository);
    await tester.pumpWidget(wrap());
    await tester.pump();
  }

  Future<void> preencherFormulario(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pump();

    final dropdowns = find.byType(DropdownButtonFormField<String>);

    await tester.tap(dropdowns.at(0)); // licitação
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pregão 01/2026').last);
    await tester.pumpAndSettle();

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'BTI Líquido'); // nome
    await tester.enterText(campos.at(1), 'L-999'); // lote

    tester
        .widget<GeopragDataNascimentoInput>(
          find.byType(GeopragDataNascimentoInput),
        )
        .onChanged(DateTime(2027, 1, 1));
    await tester.pump();

    await tester.enterText(campos.at(2), '300'); // quantidade

    await tester.tap(dropdowns.at(1)); // unidade
    await tester.pumpAndSettle();
    await tester.tap(find.text('Litros (L)').last);
    await tester.pumpAndSettle();
  }

  group('CriarProdutoCubit', () {
    testWidgets(
      'submete o formulário e persiste a entrada de verdade, resolvendo o '
      'fornecedor a partir da licitação selecionada',
      (tester) async {
        when(
          () => produtoRepository.registrarEntrada(
            nome: 'BTI Líquido',
            lote: 'L-999',
            dataValidade: DateTime(2027, 1, 1),
            quantidade: 300,
            unidadeMedida: 'Litros',
            licitacao: 'Pregão 01/2026',
            fornecedor: 'BioInsumos Ltda.',
          ),
        ).thenAnswer(
          (_) async => Produto(
            id: 'p6',
            nome: 'BTI Líquido',
            lote: 'L-999',
            dataValidade: DateTime(2027, 1, 1),
            status: 'Produto em estoque',
            quantidade: 300,
            quantidadeOriginal: 300,
            unidadeMedida: 'Litros',
            licitacao: 'Pregão 01/2026',
            fornecedor: 'BioInsumos Ltda.',
          ),
        );

        await criarCubitCarregado(tester);
        await preencherFormulario(tester);

        await tester.tap(find.text('Confirmar Entrada no Estoque'));
        await tester.pumpAndSettle();

        expect(find.text('Entrada registrada com sucesso.'), findsOneWidget);
        verify(
          () => produtoRepository.registrarEntrada(
            nome: 'BTI Líquido',
            lote: 'L-999',
            dataValidade: DateTime(2027, 1, 1),
            quantidade: 300,
            unidadeMedida: 'Litros',
            licitacao: 'Pregão 01/2026',
            fornecedor: 'BioInsumos Ltda.',
          ),
        ).called(1);
      },
    );

    testWidgets(
      'não submete sem selecionar licitação, produto, lote, validade, '
      'quantidade e unidade',
      (tester) async {
        await criarCubitCarregado(tester);
        await tester.binding.setSurfaceSize(const Size(800, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pump();

        await tester.tap(find.text('Confirmar Entrada no Estoque'));
        await tester.pump();

        verifyNever(
          () => produtoRepository.registrarEntrada(
            nome: any(named: 'nome'),
            lote: any(named: 'lote'),
            dataValidade: any(named: 'dataValidade'),
            quantidade: any(named: 'quantidade'),
            unidadeMedida: any(named: 'unidadeMedida'),
            licitacao: any(named: 'licitacao'),
            fornecedor: any(named: 'fornecedor'),
          ),
        );
        expect(find.text('Selecione a licitação.'), findsOneWidget);
        expect(find.text('Informe o produto.'), findsOneWidget);
        expect(find.text('Informe o lote.'), findsOneWidget);
        expect(find.text('Informe a validade.'), findsOneWidget);
        expect(find.text('Informe uma quantidade válida.'), findsOneWidget);
        expect(find.text('Selecione a unidade de medida.'), findsOneWidget);
      },
    );
  });
}
