import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/core/aplicador_navigator.dart';
import 'package:geoprag_modules/aplicador_app/inventory/core/recebimento.dart';
import 'package:geoprag_modules/aplicador_app/inventory/core/recebimento_repository.dart';
import 'package:geoprag_modules/aplicador_app/inventory/presentation/receber_produto_screen.dart';
import 'package:geoprag_modules/aplicador_app/inventory/presentation/recebimento_confirmacao_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockRecebimentoRepository extends Mock implements RecebimentoRepository {}

class MockAplicadorNavigator extends Mock implements AplicadorNavigator {}

void main() {
  late MockRecebimentoRepository repository;
  late MockAplicadorNavigator navigator;

  final recebimento = Recebimento(
    id: 'r1',
    produtoNome: 'BTI Líquido',
    lote: 'L-2026-0145',
    quantidadeDescricao: '1 Litro',
    agenteEntregador: 'João Silva',
    cargoAgenteEntregador: 'Fiscal de Agricultura',
    dataDespacho: DateTime(2026, 7, 5),
    status: RecebimentoStatus.pendente,
  );

  Widget wrap() => MaterialApp(
    home: AplicadorNavigatorScope(
      navigator: navigator,
      child: BlocProvider<RecebimentoConfirmacaoCubit>(
        create: (_) =>
            RecebimentoConfirmacaoCubit(repository, recebimentoId: 'r1'),
        child: const ReceberProdutoScreen(),
      ),
    ),
  );

  setUp(() {
    repository = MockRecebimentoRepository();
    navigator = MockAplicadorNavigator();
    when(() => repository.buscarPorId('r1')).thenAnswer((_) async => recebimento);
  });

  group('ReceberProdutoScreen', () {
    testWidgets(
      'mostra produto, detalhes da entrega e os dois botões',
      (tester) async {
        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        expect(find.text('BTI Líquido - 1 Litro'), findsOneWidget);
        expect(
          find.text('João Silva (Fiscal de Agricultura)'),
          findsOneWidget,
        );
        expect(find.text('L-2026-0145'), findsOneWidget);
        expect(find.text('1 Litro'), findsAtLeastNWidgets(1));
        // "Confirmar Recebimento" também é o título da AppBar — restringe
        // ao botão para não colidir com o finder.
        expect(
          find.widgetWithText(ElevatedButton, 'Confirmar Recebimento'),
          findsOneWidget,
        );
        expect(find.text('Cancelar / Voltar'), findsOneWidget);
      },
    );

    testWidgets(
      'confirmar chama o Cubit, mostra feedback e navega para o inventário',
      (tester) async {
        when(() => repository.confirmar('r1')).thenAnswer(
          (_) async => recebimento.copyWith(
            status: RecebimentoStatus.confirmado,
            confirmadoEm: DateTime(2026, 10, 20, 21, 30),
            registradoEm: DateTime(2026, 10, 20, 21, 30),
          ),
        );

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Confirmar Recebimento'),
        );
        await tester.pumpAndSettle();

        verify(() => repository.confirmar('r1')).called(1);
        expect(
          find.text('Recebimento confirmado! Estoque atualizado.'),
          findsOneWidget,
        );
        verify(() => navigator.toInventario()).called(1);
      },
    );

    testWidgets(
      'confirmação offline avisa a data/hora e que será enviada depois',
      (tester) async {
        when(() => repository.confirmar('r1')).thenAnswer(
          (_) async => recebimento.copyWith(
            status: RecebimentoStatus.confirmado,
            confirmadoEm: DateTime(2026, 10, 20, 21, 30),
          ),
        );

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Confirmar Recebimento'),
        );
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Recebimento confirmado em 20/10/2026 às 21:30. '
            'Será enviado quando houver conexão.',
          ),
          findsOneWidget,
        );
        verify(() => navigator.toInventario()).called(1);
      },
    );

    testWidgets(
      'cancelar/voltar chama o navigator sem confirmar nada',
      (tester) async {
        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        // A tela rola; com o campo Lote o botão fica abaixo da dobra do
        // viewport de teste.
        await tester.ensureVisible(find.text('Cancelar / Voltar'));
        await tester.tap(find.text('Cancelar / Voltar'));
        await tester.pumpAndSettle();

        verifyNever(() => repository.confirmar(any()));
        verify(() => navigator.back()).called(1);
      },
    );

    testWidgets(
      'mostra mensagem de erro amigável quando falha ao carregar o recebimento',
      (tester) async {
        when(
          () => repository.buscarPorId('r1'),
        ).thenThrow(Exception('offline'));

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Não foi possível carregar o recebimento'),
          findsOneWidget,
        );
        expect(find.textContaining('Exception'), findsNothing);
      },
    );
  });
}
