import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/admin_ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/editar_ponto_de_aplicacao_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/edicao_de_ponto_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../gestao_de_aplicacoes_fixtures.dart';

class MockAdminPontoDeAplicacaoRepository extends Mock
    implements AdminPontoDeAplicacaoRepository {}

class MockAdminNavigator extends Mock implements AdminNavigator {}

void main() {
  late MockAdminPontoDeAplicacaoRepository repository;
  late MockAdminNavigator navigator;

  setUp(() {
    repository = MockAdminPontoDeAplicacaoRepository();
    navigator = MockAdminNavigator();
    when(
      () => repository.buscarPorId('pa1'),
    ).thenAnswer((_) async => pontoDeAplicacao());
  });

  Future<void> montar(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdminNavigatorScope(
          navigator: navigator,
          child: BlocProvider(
            create: (_) => EditarPontoDeAplicacaoCubit(repository, 'pa1'),
            child: const EdicaoDePontoScreen(pontoId: 'pa1'),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    // GEOPRAG-150: o X sempre volta ao dashboard do módulo — diferente do
    // sucesso de envio, que volta ao detalhe do ponto editado
    // (toAplicacaoDetalhes) e é fácil de confundir com o destino do X.
    'X do formulário de edição volta ao dashboard de Aplicações, sem alteração',
    (tester) async {
      await montar(tester);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      verify(() => navigator.toAplicacoes()).called(1);
      verifyNever(() => navigator.toAplicacaoDetalhes(any()));
    },
  );

  testWidgets(
    'X do formulário de edição pede confirmação quando há campo alterado',
    (tester) async {
      await montar(tester);

      await tester.enterText(find.byType(TextFormField).first, 'Córrego Novo');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(find.text('Descartar alterações?'), findsOneWidget);
      verifyNever(() => navigator.toAplicacoes());

      await tester.tap(find.text('Descartar e sair'));
      await tester.pumpAndSettle();

      verify(() => navigator.toAplicacoes()).called(1);
    },
  );

  group('tolerância de atraso', () {
    const rotulo = 'Tolerância de atraso (dias)';
    const mensagemInvalida = 'A tolerância deve ser de pelo menos 1 dia.';

    // A tolerância é o último campo de texto do formulário, depois de
    // "Subpontos por ciclo".
    Finder campoDeTolerancia() => find.byType(TextFormField).at(11);

    Future<void> montarAlto(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await montar(tester);
    }

    testWidgets('aparece já preenchida com o padrão de 4 dias', (tester) async {
      await montarAlto(tester);

      expect(find.text(rotulo), findsOneWidget);
      expect(
        tester.widget<TextFormField>(campoDeTolerancia()).initialValue,
        '4',
      );
    });

    testWidgets('mostra a tolerância própria do ponto', (tester) async {
      when(() => repository.buscarPorId('pa1')).thenAnswer(
        (_) async => pontoDeAplicacao(toleranciaDias: 7),
      );

      await montarAlto(tester);

      expect(
        tester.widget<TextFormField>(campoDeTolerancia()).initialValue,
        '7',
      );
    });

    testWidgets(
      'com o cadastro travado, a tolerância continua editável e o resto não',
      (tester) async {
        when(() => repository.buscarPorId('pa1')).thenAnswer(
          (_) async => pontoDeAplicacao(subpontos: [execucaoDeTeste]),
        );

        await montarAlto(tester);

        final campos = find.byType(TextFormField);
        expect(tester.widget<TextFormField>(campos.at(0)).enabled, isTrue);
        expect(tester.widget<TextFormField>(campos.at(1)).enabled, isFalse);
        expect(tester.widget<TextFormField>(campos.at(10)).enabled, isFalse);
        expect(tester.widget<TextFormField>(campoDeTolerancia()).enabled, isTrue);
        expect(find.textContaining('tolerância de atraso continuam editáveis'),
            findsOneWidget);
      },
    );

    testWidgets('zero é barrado com mensagem amigável e nada é salvo',
        (tester) async {
      await montarAlto(tester);

      await tester.enterText(campoDeTolerancia(), '0');
      await tester.tap(find.text('Salvar alterações'));
      await tester.pump();

      expect(find.text(mensagemInvalida), findsOneWidget);
      verifyNever(() => repository.editarTolerancia(any(), any()));
      verifyNever(() => navigator.toAplicacaoDetalhes(any()));
    });

    testWidgets('vazio é barrado pedindo a tolerância', (tester) async {
      await montarAlto(tester);

      await tester.enterText(campoDeTolerancia(), '');
      await tester.tap(find.text('Salvar alterações'));
      await tester.pump();

      expect(find.text('Informe a tolerância de atraso em dias.'),
          findsOneWidget);
      verifyNever(() => navigator.toAplicacaoDetalhes(any()));
    });

    testWidgets(
      'cadastro travado: alterar só a tolerância salva e volta ao detalhe',
      (tester) async {
        when(() => repository.buscarPorId('pa1')).thenAnswer(
          (_) async => pontoDeAplicacao(subpontos: [execucaoDeTeste]),
        );
        when(() => repository.editarTolerancia('pa1', any()))
            .thenAnswer((_) async {});

        await montarAlto(tester);
        await tester.enterText(campoDeTolerancia(), '9');
        await tester.tap(find.text('Salvar alterações'));
        await tester.pump();
        await tester.pump();

        verify(() => repository.editarTolerancia('pa1', 9)).called(1);
        verifyNever(() => repository.editarNome(any(), any()));
        verify(() => navigator.toAplicacaoDetalhes('pa1')).called(1);
      },
    );
  });
}
