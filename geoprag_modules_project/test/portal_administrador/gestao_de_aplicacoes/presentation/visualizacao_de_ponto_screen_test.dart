import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/aplicador_resumo_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/admin_ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/ponto_de_aplicacao_detalhe_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/visualizacao_de_ponto_screen.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/widgets/atribuir_aplicador_dialog.dart';
import 'package:geoprag_modules/src/api/api_exceptions.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:mocktail/mocktail.dart';

import '../gestao_de_aplicacoes_fixtures.dart';

class MockAdminPontoDeAplicacaoRepository extends Mock
    implements AdminPontoDeAplicacaoRepository {}

class MockAplicadorRepository extends Mock implements AplicadorResumoRepository {}

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

  testWidgets(
    'trecho sem medidas e sem texto (cadastro mínimo da API) mostra "Não '
    'informado" em vez de zeros',
    (tester) async {
      when(() => repository.buscarPorId('pa1')).thenAnswer(
        (_) async => pontoDeAplicacao(
          larguraMetros: 0,
          profundidadeMetros: 0,
          velocidadeMetrosPorSegundo: 0,
          numeroReferencia: '',
          descricaoDoTrecho: '',
        ),
      );
      await montar(tester);
      await tester.pump();

      // número/referência, trecho, largura, profundidade, velocidade e vazão.
      expect(find.text('Não informado'), findsNWidgets(6));
      expect(find.text('0 m'), findsNothing);
      expect(find.textContaining('m³/s'), findsNothing);
    },
  );

  testWidgets('trecho com medidas mostra os valores e a vazão', (
    tester,
  ) async {
    when(() => repository.buscarPorId('pa1')).thenAnswer(
      (_) async => pontoDeAplicacao(
        larguraMetros: 2,
        profundidadeMetros: 0.5,
        velocidadeMetrosPorSegundo: 0.4,
      ),
    );
    await montar(tester);
    await tester.pump();

    expect(find.text('Não informado'), findsNothing);
    expect(find.textContaining('m³/s'), findsOneWidget);
  });

  testWidgets(
    'sem a lista de aplicadores (servidor fora), "Atribuir aplicador" avisa '
    'em vez de falhar em silêncio',
    (tester) async {
      when(() => repository.buscarPorId('pa1')).thenAnswer(
        (_) async => pontoDeAplicacao(),
      );
      when(() => repository.listar()).thenAnswer((_) async => []);
      when(() => aplicadorRepository.listar()).thenAnswer(
        (_) async => throw const FalhaDeConexaoException(
          'Sem conexão com o servidor.',
        ),
      );
      await montar(tester);
      await tester.pump();

      await tester.tap(find.text('Atribuir aplicador'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(AtribuirAplicadorDialog), findsNothing);
      expect(find.text('Sem conexão com o servidor.'), findsOneWidget);
    },
  );

  group('conflitos de sincronização (GEOPRAG-207)', () {
    Subponto subponto(
      String id, {
      bool conflito = false,
      MotivoDeConflito? motivo,
    }) => Subponto(
      id: id,
      latitude: -26.9312,
      longitude: -48.9567,
      realizadoEm: DateTime(2026, 8, 24, 8, 12),
      registradoEm: DateTime(2026, 8, 24, 18, 40),
      conflito: conflito,
      motivoConflito: motivo,
    );

    Future<void> abrir(WidgetTester tester, List<Subponto> subpontos) async {
      when(() => repository.buscarPorId('pa1')).thenAnswer(
        (_) async => pontoDeAplicacao(subpontos: subpontos),
      );
      await montar(tester);
      await tester.pump();
    }

    testWidgets('sem conflito, não mostra aviso nem motivo', (tester) async {
      await abrir(tester, [subponto('s1'), subponto('s2')]);

      expect(
        find.byKey(const Key('visualizacaoDePonto_avisoDeConflitos')),
        findsNothing,
      );
      expect(find.textContaining('Conflito:'), findsNothing);
      expect(find.byIcon(Icons.warning_amber), findsNothing);
    });

    testWidgets('um registro em conflito mostra o aviso, a marca e o motivo', (
      tester,
    ) async {
      await abrir(tester, [
        subponto('s1'),
        subponto(
          's2',
          conflito: true,
          motivo: MotivoDeConflito.pontoReatribuido,
        ),
      ]);

      expect(
        find.text('1 registro chegou em conflito com o estado do ponto.'),
        findsOneWidget,
      );
      expect(find.textContaining('Conflito: o ponto foi reatribuído'), findsOneWidget);
      // O ícone de alerta marca a linha e o aviso; a linha sem conflito não tem.
      expect(find.byIcon(Icons.warning_amber), findsNWidgets(2));
      expect(find.byIcon(Icons.place_outlined), findsOneWidget);
    });

    testWidgets('vários registros em conflito são contados no aviso', (
      tester,
    ) async {
      await abrir(tester, [
        subponto('s1', conflito: true, motivo: MotivoDeConflito.dataCancelada),
        subponto('s2', conflito: true, motivo: MotivoDeConflito.dataJaAtendida),
        subponto('s3'),
      ]);

      expect(
        find.text('2 registros chegaram em conflito com o estado do ponto.'),
        findsOneWidget,
      );
    });

    final textos = {
      MotivoDeConflito.pontoReatribuido: 'o ponto foi reatribuído',
      MotivoDeConflito.pontoDesativado: 'o ponto estava desativado',
      MotivoDeConflito.pontoInativo: 'o ciclo do ponto estava encerrado',
      MotivoDeConflito.dataJaAtendida: 'a data agendada já tinha sido atendida',
      MotivoDeConflito.dataCancelada: 'a data agendada estava cancelada',
      MotivoDeConflito.desconhecido: 'o registro chegou em desacordo',
      null: 'o registro chegou em desacordo',
    };
    for (final MapEntry(key: motivo, value: trecho) in textos.entries) {
      testWidgets('motivo $motivo mostra o texto em português', (tester) async {
        await abrir(tester, [subponto('s1', conflito: true, motivo: motivo)]);

        expect(find.textContaining('Conflito: $trecho'), findsOneWidget);
      });
    }
  });

  testWidgets(
    // GEOPRAG-142: o bloco de auditoria foi removido da tela, mas o
    // histórico de execuções (informação de negócio legítima e distinta de
    // auditoria) continua visível.
    'não mostra o bloco de auditoria, mas mantém o histórico de execuções',
    (tester) async {
      when(() => repository.buscarPorId('pa1')).thenAnswer(
        (_) async => pontoDeAplicacao(subpontos: [execucaoDeTeste]),
      );
      await montar(tester);
      await tester.pump();

      expect(find.text('Auditoria'), findsNothing);
      expect(find.text('Execuções realizadas'), findsOneWidget);
      expect(find.textContaining('Aplicada em'), findsOneWidget);
    },
  );
}
