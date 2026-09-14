import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/core/aplicador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/admin_ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/ponto_de_aplicacao_detalhe_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/visualizacao_de_ponto_screen.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:mocktail/mocktail.dart';

import '../gestao_de_aplicacoes_fixtures.dart';

class MockAdminPontoDeAplicacaoRepository extends Mock
    implements AdminPontoDeAplicacaoRepository {}

class MockAplicadorRepository extends Mock implements AplicadorRepository {}

class MockAdminNavigator extends Mock implements AdminNavigator {}

void main() {
  late MockAdminPontoDeAplicacaoRepository repository;
  late MockAplicadorRepository aplicadorRepository;
  late MockAdminNavigator navigator;

  setUp(() {
    repository = MockAdminPontoDeAplicacaoRepository();
    aplicadorRepository = MockAplicadorRepository();
    navigator = MockAdminNavigator();
  });

  Future<void> montar(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdminNavigatorScope(
          navigator: navigator,
          child: BlocProvider(
            create: (_) => PontoDeAplicacaoDetalheCubit(
              repository,
              aplicadorRepository,
              'pa1',
            ),
            child: const VisualizacaoDePontoScreen(),
          ),
        ),
      ),
    );
  }

  testWidgets(
    // GEOPRAG-151: esta tela tem 3 níveis de profundidade — o ← precisa
    // voltar ao bairro do ponto (com o parâmetro certo), não ao dashboard
    // geral de Aplicações, que é o comportamento errado mais fácil de
    // escrever por engano aqui.
    '← volta ao bairro do ponto quando já carregado',
    (tester) async {
      when(
        () => repository.buscarPorId('pa1'),
      ).thenAnswer((_) async => pontoDeAplicacao(bairro: 'Gasparinho'));
      await montar(tester);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      verify(() => navigator.toAplicacaoBairro('Gasparinho')).called(1);
      verifyNever(() => navigator.toAplicacoes());
    },
  );

  testWidgets(
    '← cai no dashboard de Aplicações enquanto o ponto ainda está carregando',
    (tester) async {
      // Nunca resolve — a tela permanece em loading durante o teste.
      when(
        () => repository.buscarPorId('pa1'),
      ).thenAnswer((_) => Completer<PontoDeAplicacao>().future);
      await montar(tester);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      verify(() => navigator.toAplicacoes()).called(1);
      verifyNever(() => navigator.toAplicacaoBairro(any()));
    },
  );
}
