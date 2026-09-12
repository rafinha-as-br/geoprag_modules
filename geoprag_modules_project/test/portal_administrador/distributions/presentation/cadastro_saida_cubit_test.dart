import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/distributions/core/distribuicao.dart';
import 'package:geoprag_modules/portal_administrador/distributions/core/distribuicao_repository.dart';
import 'package:geoprag_modules/portal_administrador/distributions/core/produto_referencia_distribuicao.dart';
import 'package:geoprag_modules/portal_administrador/distributions/core/responsavel_referencia_distribuicao.dart';
import 'package:geoprag_modules/portal_administrador/distributions/presentation/cadastro_saida_cubit.dart';
import 'package:geoprag_modules/src/widgets/base_form_screen.dart';
import 'package:geoprag_modules/src/widgets/geoprag_data_nascimento_input.dart';
import 'package:mocktail/mocktail.dart';

class MockDistribuicaoRepository extends Mock implements DistribuicaoRepository {}

void main() {
  late MockDistribuicaoRepository repository;
  late CadastroSaidaCubit cubit;

  const produto = ProdutoReferenciaDistribuicao(
    id: 'p1',
    nomeExibicao: 'BTI Líquido',
  );
  const responsavel = ResponsavelReferenciaDistribuicao(
    id: '1',
    nome: 'João Silva',
    bairro: 'Belchior',
  );

  Widget wrap() => MaterialApp(
    home: Scaffold(
      body: BlocProvider<CadastroSaidaCubit>.value(
        value: cubit,
        child: const BaseFormScreen<CadastroSaidaCubit>(),
      ),
    ),
  );

  setUp(() {
    repository = MockDistribuicaoRepository();
  });

  /// Cria o cubit já com as opções carregadas — evita repetir o stub de
  /// carregamento em todo teste que só se importa com a submissão.
  Future<void> criarCubitCarregado(WidgetTester tester) async {
    when(
      () => repository.listarProdutosDisponiveis(),
    ).thenAnswer((_) async => const [produto]);
    when(
      () => repository.listarResponsaveisDisponiveis(),
    ).thenAnswer((_) async => const [responsavel]);
    cubit = CadastroSaidaCubit(repository);
    await tester.pumpWidget(wrap());
    await tester.pump();
  }

  /// Preenche todos os campos obrigatórios do formulário na tela pumpada por
  /// [wrap]. Os dropdowns são pilotados por toque real (abrir o menu, tocar
  /// no item) — diferente de `GeopragXxxInput`, `DropdownButtonFormField` cru
  /// não expõe `onChanged` como atalho de teste.
  Future<void> preencherFormulario(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pump();

    final dropdowns = find.byType(DropdownButtonFormField<String>);

    await tester.tap(dropdowns.at(0)); // produto
    await tester.pumpAndSettle();
    await tester.tap(find.text('BTI Líquido').last);
    await tester.pumpAndSettle();

    await tester.tap(dropdowns.at(1)); // responsável
    await tester.pumpAndSettle();
    await tester.tap(find.text('João Silva - Belchior').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '10');

    await tester.tap(dropdowns.at(2)); // unidade
    await tester.pumpAndSettle();
    await tester.tap(find.text('Litros').last);
    await tester.pumpAndSettle();

    tester
        .widget<GeopragDataNascimentoInput>(
          find.byType(GeopragDataNascimentoInput),
        )
        .onChanged(DateTime(2026, 7, 5));
    await tester.pump();
  }

  group('CadastroSaidaCubit', () {
    testWidgets(
      'desabilita o botão de envio enquanto carrega as opções',
      (tester) async {
        final opcoesPendentes = Completer<List<ProdutoReferenciaDistribuicao>>();
        when(
          () => repository.listarProdutosDisponiveis(),
        ).thenAnswer((_) => opcoesPendentes.future);
        when(
          () => repository.listarResponsaveisDisponiveis(),
        ).thenAnswer((_) async => const [responsavel]);
        cubit = CadastroSaidaCubit(repository);

        await tester.pumpWidget(wrap());
        await tester.pump();

        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNull,
        );

        opcoesPendentes.complete(const [produto]);
        await tester.pumpAndSettle();

        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNotNull,
        );
      },
    );

    testWidgets(
      'emite feedback de erro amigável quando falha ao carregar as opções '
      '(nunca expõe a exceção bruta ao usuário)',
      (tester) async {
        when(
          () => repository.listarProdutosDisponiveis(),
        ).thenAnswer((_) async => throw Exception('offline'));
        when(
          () => repository.listarResponsaveisDisponiveis(),
        ).thenAnswer((_) async => const []);
        cubit = CadastroSaidaCubit(repository);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        expect(find.textContaining('Exception'), findsNothing);
        expect(
          find.text('Não foi possível carregar os dados. Tente novamente.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'tocar o botão sem opções carregadas não derruba a tela '
      '(cai no catch genérico de onSubmit)',
      (tester) async {
        when(
          () => repository.listarProdutosDisponiveis(),
        ).thenAnswer((_) async => throw Exception('offline'));
        when(
          () => repository.listarResponsaveisDisponiveis(),
        ).thenAnswer((_) async => const []);
        cubit = CadastroSaidaCubit(repository);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        // Sem produtos/responsáveis, fields fica vazio e o Form não tem
        // nenhum FormField registrado — validate() passa vazio e onSubmit()
        // roda com _produtoId/_unidade/_dataEntrega ainda nulos. O teste
        // trava aqui se isso virar uma exceção não capturada.
        await tester.tap(find.text('Confirmar Saída e Gerar Documento'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'submete o formulário e persiste a distribuição de verdade',
      (tester) async {
        when(
          () => repository.criar(
            produtoId: 'p1',
            quantidade: 10,
            unidade: 'Litros',
            dataEntrega: DateTime(2026, 7, 5),
            responsavel: 'João Silva',
            bairroResponsavel: 'Belchior',
          ),
        ).thenAnswer(
          (_) async => Distribuicao(
            id: 'd6',
            produtoId: 'p1',
            quantidade: 10,
            unidade: 'Litros',
            dataEntrega: DateTime(2026, 7, 5),
            responsavel: 'João Silva',
            bairroResponsavel: 'Belchior',
            statusConfirmacao: 'aguardando_aceite',
          ),
        );

        await criarCubitCarregado(tester);
        await preencherFormulario(tester);

        await tester.tap(find.text('Confirmar Saída e Gerar Documento'));
        await tester.pumpAndSettle();

        expect(find.text('Saída registrada com sucesso.'), findsOneWidget);
        verify(
          () => repository.criar(
            produtoId: 'p1',
            quantidade: 10,
            unidade: 'Litros',
            dataEntrega: DateTime(2026, 7, 5),
            responsavel: 'João Silva',
            bairroResponsavel: 'Belchior',
          ),
        ).called(1);
      },
    );

    testWidgets(
      'não submete sem selecionar produto, responsável, quantidade, unidade '
      'e data',
      (tester) async {
        await criarCubitCarregado(tester);
        await tester.binding.setSurfaceSize(const Size(800, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pump();

        await tester.tap(find.text('Confirmar Saída e Gerar Documento'));
        await tester.pump();

        verifyNever(
          () => repository.criar(
            produtoId: any(named: 'produtoId'),
            quantidade: any(named: 'quantidade'),
            unidade: any(named: 'unidade'),
            dataEntrega: any(named: 'dataEntrega'),
            responsavel: any(named: 'responsavel'),
            bairroResponsavel: any(named: 'bairroResponsavel'),
          ),
        );
        expect(find.text('Selecione o produto.'), findsOneWidget);
        expect(find.text('Selecione o responsável.'), findsOneWidget);
        expect(find.text('Informe uma quantidade válida.'), findsOneWidget);
        expect(find.text('Selecione a unidade.'), findsOneWidget);
        expect(find.text('Informe a data da entrega.'), findsOneWidget);
      },
    );
  });
}
