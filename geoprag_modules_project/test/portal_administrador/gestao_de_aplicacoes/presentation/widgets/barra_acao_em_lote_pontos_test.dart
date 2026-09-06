import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/core/aplicador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/admin_ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/pontos_do_bairro_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/widgets/barra_acao_em_lote_pontos.dart';
import 'package:mocktail/mocktail.dart';

import '../../gestao_de_aplicacoes_fixtures.dart';

class MockAdminPontoDeAplicacaoRepository extends Mock
    implements AdminPontoDeAplicacaoRepository {}

class MockAplicadorRepository extends Mock implements AplicadorRepository {}

void main() {
  group('BarraAcaoEmLotePontos', () {
    late MockAdminPontoDeAplicacaoRepository repository;
    late MockAplicadorRepository aplicadorRepository;
    late PontosDoBairroCubit cubit;

    setUp(() async {
      repository = MockAdminPontoDeAplicacaoRepository();
      aplicadorRepository = MockAplicadorRepository();
      when(() => aplicadorRepository.listar()).thenAnswer((_) async => []);
      when(
        () => repository.listarPorBairro('Gasparinho'),
      ).thenAnswer((_) async => [pontoDeAplicacao(), pontoDeAplicacao(id: 'pa2')]);
      cubit = PontosDoBairroCubit(repository, aplicadorRepository, 'Gasparinho');
      await Future<void>.delayed(Duration.zero);
    });

    Widget wrap() => MaterialApp(
      home: Scaffold(
        body: BlocProvider.value(
          value: cubit,
          child: BarraAcaoEmLotePontos(cubit: cubit),
        ),
      ),
    );

    testWidgets('fica invisível e não interativa sem seleção', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());

      final opacity = tester.widget<Opacity>(
        find.byKey(const Key('barraAcaoEmLotePontos_opacity')),
      );
      final ignorePointer = tester.widget<IgnorePointer>(
        find.byKey(const Key('barraAcaoEmLotePontos_ignorePointer')),
      );
      expect(opacity.opacity, 0);
      expect(ignorePointer.ignoring, isTrue);
    });

    testWidgets('fica visível e interativa com pelo menos um selecionado', (
      tester,
    ) async {
      cubit.alternarSelecao(cubit.state.items.first);
      await tester.pumpWidget(wrap());

      final opacity = tester.widget<Opacity>(
        find.byKey(const Key('barraAcaoEmLotePontos_opacity')),
      );
      final ignorePointer = tester.widget<IgnorePointer>(
        find.byKey(const Key('barraAcaoEmLotePontos_ignorePointer')),
      );
      expect(opacity.opacity, 1);
      expect(ignorePointer.ignoring, isFalse);
      expect(find.text('1 selecionado(s)'), findsOneWidget);
    });

    testWidgets('mostra a contagem correta com mais de um selecionado', (
      tester,
    ) async {
      cubit.alternarSelecaoDeTodosVisiveis();
      await tester.pumpWidget(wrap());

      expect(find.text('2 selecionado(s)'), findsOneWidget);
    });

    testWidgets('"Limpar seleção" esvazia a seleção do cubit', (
      tester,
    ) async {
      cubit.alternarSelecaoDeTodosVisiveis();
      await tester.pumpWidget(wrap());

      await tester.tap(find.text('Limpar seleção'));
      await tester.pump();

      expect(cubit.state.idsSelecionados, isEmpty);
    });

    testWidgets('desabilita os botões enquanto processandoAcaoEmLote', (
      tester,
    ) async {
      cubit.alternarSelecao(cubit.state.items.first);
      cubit.emitProcessandoAcaoEmLote(true);
      await tester.pumpWidget(wrap());

      final ativar = tester.widget<OutlinedButton>(
        find.byKey(const Key('barraAcaoEmLotePontos_ativar')),
      );
      expect(ativar.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
