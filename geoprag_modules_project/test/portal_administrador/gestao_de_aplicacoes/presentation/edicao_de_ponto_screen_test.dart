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
}
