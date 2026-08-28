import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/distributions/core/distribuicao.dart';
import 'package:geoprag_modules/portal_administrador/distributions/core/distribuicao_repository.dart';
import 'package:geoprag_modules/portal_administrador/distributions/presentation/distribuicao_detalhe_cubit.dart';
import 'package:geoprag_modules/portal_administrador/distributions/presentation/visualizacao_saida_screen.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:mocktail/mocktail.dart';

class MockDistribuicaoRepository extends Mock implements DistribuicaoRepository {}

void main() {
  late MockDistribuicaoRepository repository;

  final distribuicao = Distribuicao(
    id: 'd1',
    produtoId: 'p1',
    quantidade: 2,
    unidade: 'Litros',
    dataEntrega: DateTime(2026, 6, 1),
    responsavel: 'João Silva',
    bairroResponsavel: 'Belchior',
    statusConfirmacao: 'confirmado',
  );

  setUp(() {
    repository = MockDistribuicaoRepository();
  });

  Widget wrap(String distribuicaoId) => MaterialApp(
    home: BlocProvider(
      create: (_) => DistribuicaoDetalheCubit(repository, distribuicaoId),
      child: const VisualizacaoSaidaScreen(),
    ),
  );

  testWidgets('mostra spinner enquanto a distribuição carrega', (
    tester,
  ) async {
    when(
      () => repository.buscarPorId('d1'),
    ).thenAnswer((_) async => distribuicao);
    when(
      () => repository.buscarNomeProduto('p1'),
    ).thenAnswer((_) async => 'BTI Líquido - Lote L-001');

    await tester.pumpWidget(wrap('d1'));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
    'mostra título fixo, cartão centralizado, ações (imprimir + editar) no '
    'header e o aviso de restrição de edição quando a distribuição carrega',
    (tester) async {
      when(
        () => repository.buscarPorId('d1'),
      ).thenAnswer((_) async => distribuicao);
      when(
        () => repository.buscarNomeProduto('p1'),
      ).thenAnswer((_) async => 'BTI Líquido - Lote L-001');

      // A variante cartão centralizado não tem scroll (mesmo comportamento
      // de antes da migração) — usa um viewport de teste alto o bastante
      // para o conteúdo completo, evitando overflow que só existe por
      // causa do tamanho fixo da janela de teste.
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap('d1'));
      await tester.pumpAndSettle();

      expect(find.text('Comprovante de Saída'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
      expect(find.byIcon(Icons.print), findsOneWidget);
      expect(find.text('Editar Registro'), findsOneWidget);
      expect(
        find.text(
          'Nota: Este documento de saída permite edição apenas em campos '
          'não-críticos e não pode ser excluído.',
        ),
        findsOneWidget,
      );
      expect(find.text('BTI Líquido - Lote L-001'), findsOneWidget);
    },
  );

  testWidgets(
    'mostra mensagem amigável de erro quando a distribuição não é encontrada',
    (tester) async {
      when(() => repository.buscarPorId('inexistente')).thenAnswer(
        (_) async => throw const EntidadeNaoEncontradaException(
          'Distribuição "inexistente" não encontrada.',
        ),
      );

      await tester.pumpWidget(wrap('inexistente'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Não foi possível carregar a distribuição: '
          'Distribuição "inexistente" não encontrada.',
        ),
        findsOneWidget,
      );
    },
  );
}
