import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/aplicacao_de_campo_view_model.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/tela_de_aplicacao_cubit.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/tela_de_aplicacao_screen.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/tela_de_aplicacao_state.dart';
import 'package:geoprag_modules/aplicador_app/core/aplicador_navigator.dart';
import 'package:geoprag_modules/src/entities/produto.dart';
import 'package:mocktail/mocktail.dart';

class MockTelaDeAplicacaoCubit extends MockCubit<TelaDeAplicacaoState>
    implements TelaDeAplicacaoCubit {}

class MockAplicadorNavigator extends Mock implements AplicadorNavigator {}

void main() {
  late MockTelaDeAplicacaoCubit cubit;
  late MockAplicadorNavigator navigator;

  Widget wrap(TelaDeAplicacaoState state) {
    cubit = MockTelaDeAplicacaoCubit();
    navigator = MockAplicadorNavigator();
    whenListen(cubit, Stream.value(state), initialState: state);
    when(() => cubit.registrarSubponto()).thenAnswer((_) async {});
    when(() => cubit.selecionarProduto(any())).thenReturn(null);
    return MaterialApp(
      home: AplicadorNavigatorScope(
        navigator: navigator,
        child: BlocProvider<TelaDeAplicacaoCubit>.value(
          value: cubit,
          child: const TelaDeAplicacaoScreen(),
        ),
      ),
    );
  }

  const ponto = PontoParaAplicacaoViewModel(
    id: 'pa1',
    nome: 'Córrego Gasparinho',
    identificador: '#GAS1',
    enderecoFormatado: 'Rua Pedro Simon, Em frente ao nº 240',
    dosagemFormatada: '120 ml',
    distanciaEntreSubpontosMetros: 50,
    quantidadeDeSubpontos: 2,
    execucoesRegistradas: 0,
  );

  const larvicida = Produto(id: 'produto-1', nome: 'Larvicida');
  const outro = Produto(id: 'produto-2', nome: 'Outro');

  group('TelaDeAplicacaoScreen', () {
    testWidgets('mostra dosagem e o contador de subpontos', (tester) async {
      await tester.pumpWidget(
        wrap(const TelaDeAplicacaoEmAndamento(ponto: ponto)),
      );

      expect(find.text('120 ml'), findsOneWidget);
      expect(find.text('Subponto 0 de 2'), findsOneWidget);
      expect(find.text('Registrar Subponto'), findsOneWidget);
    });

    testWidgets('toca em "Registrar Subponto" e chama o cubit', (tester) async {
      await tester.pumpWidget(
        wrap(
          const TelaDeAplicacaoEmAndamento(
            ponto: ponto,
            produtos: [larvicida],
            produtoSelecionadoId: 'produto-1',
          ),
        ),
      );

      await tester.ensureVisible(find.text('Registrar Subponto'));
      await tester.tap(find.text('Registrar Subponto'));
      verify(() => cubit.registrarSubponto()).called(1);
    });

    testWidgets(
      'sem posição do GPS mostra a orientação e mantém o botão para tentar de novo',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            const TelaDeAplicacaoEmAndamento(
              ponto: ponto,
              produtos: [larvicida],
              produtoSelecionadoId: 'produto-1',
              mensagemDeErro: 'O GPS está desligado.',
            ),
          ),
        );

        expect(find.text('O GPS está desligado.'), findsOneWidget);
        expect(
          tester
              .widget<ElevatedButton>(
                find.byKey(
                  const Key('telaDeAplicacaoScreen_registrarSubponto'),
                ),
              )
              .onPressed,
          isNotNull,
        );
        expect(find.text('Cancelar / Voltar'), findsOneWidget);
      },
    );

    testWidgets('sem produto escolhido o botão fica desligado e o seletor '
        'lista os produtos do aparelho', (tester) async {
      await tester.pumpWidget(
        wrap(
          const TelaDeAplicacaoEmAndamento(
            ponto: ponto,
            produtos: [larvicida, outro],
          ),
        ),
      );

      expect(
        tester
            .widget<ElevatedButton>(
              find.byKey(const Key('telaDeAplicacaoScreen_registrarSubponto')),
            )
            .onPressed,
        isNull,
      );

      await tester.ensureVisible(
        find.byKey(const Key('telaDeAplicacaoScreen_produto')),
      );
      await tester.tap(find.byKey(const Key('telaDeAplicacaoScreen_produto')));
      await tester.pumpAndSettle();
      expect(find.text('Larvicida'), findsWidgets);
      await tester.tap(find.text('Outro').last);
      await tester.pumpAndSettle();
      verify(() => cubit.selecionarProduto('produto-2')).called(1);
    });

    testWidgets('sem nenhum produto no aparelho explica e não deixa registrar',
        (tester) async {
      await tester.pumpWidget(
        wrap(const TelaDeAplicacaoEmAndamento(ponto: ponto)),
      );

      expect(
        find.byKey(const Key('telaDeAplicacaoScreen_semProdutos')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<ElevatedButton>(
              find.byKey(const Key('telaDeAplicacaoScreen_registrarSubponto')),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets('depois do primeiro subponto o produto não muda mais',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          const TelaDeAplicacaoEmAndamento(
            ponto: ponto,
            subpontosRegistrados: 1,
            produtos: [larvicida, outro],
            produtoSelecionadoId: 'produto-1',
          ),
        ),
      );

      final seletor = tester.widget<DropdownButtonFormField<String>>(
        find.byKey(const Key('telaDeAplicacaoScreen_produto')),
      );
      expect(seletor.onChanged, isNull);
    });

    testWidgets('mostra spinner no botão enquanto registrando', (tester) async {
      await tester.pumpWidget(
        wrap(const TelaDeAplicacaoEmAndamento(ponto: ponto, registrando: true)),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester
            .widget<ElevatedButton>(
              find.byKey(const Key('telaDeAplicacaoScreen_registrarSubponto')),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets(
      'ao concluir, mostra sucesso e "Voltar para Meus Pontos" navega para /ponto',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            const TelaDeAplicacaoEmAndamento(
              ponto: ponto,
              subpontosRegistrados: 2,
            ),
          ),
        );

        expect(
          find.textContaining('Aplicação registrada com sucesso'),
          findsOneWidget,
        );
        expect(find.text('Registrar Subponto'), findsNothing);

        await tester.ensureVisible(find.text('Voltar para Meus Pontos'));
        await tester.tap(find.text('Voltar para Meus Pontos'));
        verify(() => navigator.toPonto()).called(1);
      },
    );

    testWidgets(
      // GEOPRAG-152: X precisa distinguir "cancelar etapa em andamento"
      // (back()) de "sair após concluir" (toPonto()) — é a única lógica
      // condicional desta issue e onde um erro de fato quebraria o fluxo.
      'X cancela a etapa (back) enquanto a aplicação ainda não foi concluída',
      (tester) async {
        await tester.pumpWidget(
          wrap(const TelaDeAplicacaoEmAndamento(ponto: ponto)),
        );

        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();

        verify(() => navigator.back()).called(1);
        verifyNever(() => navigator.toPonto());
      },
    );

    testWidgets('X vai para Meus Pontos (toPonto) quando já concluída', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const TelaDeAplicacaoEmAndamento(
            ponto: ponto,
            subpontosRegistrados: 2,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      verify(() => navigator.toPonto()).called(1);
      verifyNever(() => navigator.back());
    });
  });
}
