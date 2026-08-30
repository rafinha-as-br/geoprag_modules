import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/licitacao.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/core/licitacao_repository.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/presentation/criar_licitacao_cubit.dart';
import 'package:geoprag_modules/src/widgets/base_form_screen.dart';
import 'package:geoprag_modules/src/widgets/geoprag_data_nascimento_input.dart';
import 'package:mocktail/mocktail.dart';

class MockLicitacaoRepository extends Mock implements LicitacaoRepository {}

void main() {
  late MockLicitacaoRepository repository;
  late CriarLicitacaoCubit cubit;

  Widget wrap() => MaterialApp(
    home: Scaffold(
      body: BlocProvider<CriarLicitacaoCubit>.value(
        value: cubit,
        child: const BaseFormScreen<CriarLicitacaoCubit>(),
      ),
    ),
  );

  setUp(() {
    repository = MockLicitacaoRepository();
    cubit = CriarLicitacaoCubit(repository);
  });

  Future<void> preencherFormulario(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Pregão 03/2026');
    await tester.enterText(campos.at(1), 'Nova Fornecedora Ltda.');
    await tester.enterText(campos.at(2), 'Aquisição de EPI');
    await tester.enterText(campos.at(3), '15000');

    tester
        .widget<GeopragDataNascimentoInput>(
          find.byType(GeopragDataNascimentoInput),
        )
        .onChanged(DateTime(2026, 8, 1));
    await tester.pump();
  }

  group('CriarLicitacaoCubit', () {
    testWidgets(
      'submete o formulário e persiste a licitação de verdade',
      (tester) async {
        when(
          () => repository.criar(
            numeroAno: 'Pregão 03/2026',
            fornecedorVencedor: 'Nova Fornecedora Ltda.',
            objetoLicitado: 'Aquisição de EPI',
            valorTotal: 15000,
            dataHomologacao: DateTime(2026, 8, 1),
          ),
        ).thenAnswer(
          (_) async => Licitacao(
            id: 'l3',
            numeroAno: 'Pregão 03/2026',
            fornecedorVencedor: 'Nova Fornecedora Ltda.',
            objetoLicitado: 'Aquisição de EPI',
            valorTotal: 15000,
            dataHomologacao: DateTime(2026, 8, 1),
          ),
        );

        await tester.pumpWidget(wrap());
        await preencherFormulario(tester);

        await tester.tap(find.text('Salvar Licitação'));
        await tester.pumpAndSettle();

        expect(
          find.text('Licitação registrada com sucesso.'),
          findsOneWidget,
        );
        verify(
          () => repository.criar(
            numeroAno: 'Pregão 03/2026',
            fornecedorVencedor: 'Nova Fornecedora Ltda.',
            objetoLicitado: 'Aquisição de EPI',
            valorTotal: 15000,
            dataHomologacao: DateTime(2026, 8, 1),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'não submete e mostra as mensagens de validação com o formulário vazio',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(wrap());

        await tester.tap(find.text('Salvar Licitação'));
        await tester.pump();

        verifyNever(
          () => repository.criar(
            numeroAno: any(named: 'numeroAno'),
            fornecedorVencedor: any(named: 'fornecedorVencedor'),
            objetoLicitado: any(named: 'objetoLicitado'),
            valorTotal: any(named: 'valorTotal'),
            dataHomologacao: any(named: 'dataHomologacao'),
          ),
        );
        expect(find.text('Informe o número e ano.'), findsOneWidget);
        expect(find.text('Informe o fornecedor vencedor.'), findsOneWidget);
        expect(find.text('Informe o objeto licitado.'), findsOneWidget);
        expect(find.text('Informe um valor válido.'), findsOneWidget);
        expect(find.text('Informe a data da homologação.'), findsOneWidget);
      },
    );
  });
}
