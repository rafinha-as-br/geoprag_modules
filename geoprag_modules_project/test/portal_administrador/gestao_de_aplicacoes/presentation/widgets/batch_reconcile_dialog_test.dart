import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/lote_de_pontos_reconciliacao.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/ponto_de_aplicacao_view_model.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/widgets/batch_reconcile_dialog.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';

PontoDeAplicacaoResumoViewModel _item(
  String id,
  EstadoPontoDeAplicacao estado,
) => PontoDeAplicacaoResumoViewModel(
  id: id,
  identificador: '#$id',
  nome: 'Ponto $id',
  bairro: 'Gasparinho',
  estado: estado,
  aplicadorNome: null,
  execucoesRegistradas: 0,
  quantidadeDeSubpontos: 1,
  ativoSemRegistro: false,
);

class _Resultado {
  BatchReconcileConfirmado? valor;
}

Future<_Resultado> _abrir(
  WidgetTester tester, {
  required AcaoEmLote acao,
  required ReconciliacaoDoLote reconciliacao,
  List<AplicadorOpcao>? aplicadoresDisponiveis,
}) async {
  final resultado = _Resultado();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              resultado.valor = await showDialog<BatchReconcileConfirmado>(
                context: context,
                builder: (_) => BatchReconcileDialog(
                  acao: acao,
                  reconciliacao: reconciliacao,
                  aplicadoresDisponiveis: aplicadoresDisponiveis,
                ),
              );
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
  return resultado;
}

void main() {
  group('BatchReconcileDialog', () {
    testWidgets('lista elegíveis e ignorados (com motivo)', (tester) async {
      final reconciliacao = reconciliarLote(
        acao: AcaoEmLote.desativar,
        selecionados: [
          _item('a', EstadoPontoDeAplicacao.ativa),
          _item('b', EstadoPontoDeAplicacao.desativado),
        ],
      );

      await _abrir(tester, acao: AcaoEmLote.desativar, reconciliacao: reconciliacao);

      expect(find.textContaining('1 de 2'), findsOneWidget);
      expect(find.text('• Ponto a'), findsOneWidget);
      expect(find.textContaining('Ponto b — Estado atual'), findsOneWidget);
    });

    testWidgets('sem elegíveis não mostra o botão Confirmar', (tester) async {
      final reconciliacao = reconciliarLote(
        acao: AcaoEmLote.atribuirAplicador,
        selecionados: [_item('a', EstadoPontoDeAplicacao.ativa)],
      );

      await _abrir(
        tester,
        acao: AcaoEmLote.atribuirAplicador,
        reconciliacao: reconciliacao,
      );

      expect(find.text('Confirmar'), findsNothing);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('desativar: Confirmar já habilitado (sem formulário extra)', (
      tester,
    ) async {
      final reconciliacao = reconciliarLote(
        acao: AcaoEmLote.desativar,
        selecionados: [_item('a', EstadoPontoDeAplicacao.ativa)],
      );

      final resultado = await _abrir(
        tester,
        acao: AcaoEmLote.desativar,
        reconciliacao: reconciliacao,
      );
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(resultado.valor, isNotNull);
      expect(resultado.valor!.agendamento, isNull);
      expect(resultado.valor!.aplicadorId, isNull);
    });

    testWidgets(
      'atribuirAplicador: Confirmar começa desabilitado até escolher um aplicador',
      (tester) async {
        final reconciliacao = reconciliarLote(
          acao: AcaoEmLote.atribuirAplicador,
          selecionados: [_item('a', EstadoPontoDeAplicacao.enderecada)],
        );

        await _abrir(
          tester,
          acao: AcaoEmLote.atribuirAplicador,
          reconciliacao: reconciliacao,
          aplicadoresDisponiveis: const [
            AplicadorOpcao(id: '1', nome: 'João Silva'),
          ],
        );

        final confirmar = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Confirmar'));
        expect(confirmar.onPressed, isNull);

        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('João Silva').last);
        await tester.pumpAndSettle();

        final confirmarHabilitado = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Confirmar'),
        );
        expect(confirmarHabilitado.onPressed, isNotNull);
      },
    );

    testWidgets(
      'ativar: Confirmar começa desabilitado até escolher a data',
      (tester) async {
        final reconciliacao = reconciliarLote(
          acao: AcaoEmLote.ativar,
          selecionados: [_item('a', EstadoPontoDeAplicacao.direcionada)],
        );

        await _abrir(tester, acao: AcaoEmLote.ativar, reconciliacao: reconciliacao);

        final confirmar = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Confirmar'),
        );
        expect(confirmar.onPressed, isNull);
        expect(find.text('Escolher data da 1ª aplicação'), findsOneWidget);
      },
    );
  });
}
