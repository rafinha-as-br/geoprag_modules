import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/sincronizacao/sincronizacao.dart';
import 'package:mocktail/mocktail.dart';

class PainelFalso extends Mock implements PainelDeSincronizacao {}

RegistroSincronizavel registro(
  String id,
  SituacaoDoRegistro situacao, {
  String? pontoNome = 'Córrego Gasparinho',
  String? motivo,
}) => RegistroSincronizavel(
  id: id,
  pontoId: 'ponto-1',
  pontoNome: pontoNome,
  registradoEm: DateTime(2026, 10, 21, 9, 30),
  situacao: situacao,
  motivo: motivo,
);

void main() {
  late PainelFalso painel;

  void painelCom(SituacaoDaSincronizacao situacao) {
    painel = PainelFalso();
    when(() => painel.aoMudar).thenAnswer((_) => const Stream<void>.empty());
    when(painel.carregar).thenAnswer((_) async => situacao);
  }

  Future<void> abrirTela(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => SincronizacaoCubit(painel),
          child: const SincronizacaoScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('SincronizacaoScreen', () {
    testWidgets(
      'mostra pendente, enviado e rejeitado com o motivo, sem nenhuma '
      'ação sobre o registro',
      (tester) async {
        painelCom(
          SituacaoDaSincronizacao(
            registros: [
              registro('s-3', SituacaoDoRegistro.pendente),
              registro(
                's-2',
                SituacaoDoRegistro.rejeitado,
                motivo: 'O ponto informado não existe.',
              ),
              registro('s-1', SituacaoDoRegistro.enviado, pontoNome: null),
            ],
            ultimaSincronizacao: DateTime(2026, 10, 21, 10, 5),
          ),
        );

        await abrirTela(tester);

        expect(find.text('Pendente'), findsOneWidget);
        expect(find.text('Enviado'), findsOneWidget);
        expect(find.text('Rejeitado'), findsOneWidget);
        expect(find.text('O ponto informado não existe.'), findsOneWidget);
        expect(find.text('Ponto de aplicação'), findsOneWidget);
        expect(find.text('1 registro pendente de envio'), findsOneWidget);
        expect(
          find.text('Última sincronização: 21/10/2026 às 10:05'),
          findsOneWidget,
        );
        // Só "Sincronizar agora" é botão; o registro rejeitado é só consulta.
        expect(find.bySubtype<FilledButton>(), findsOneWidget);
        expect(find.byType(TextButton), findsNothing);
        expect(find.byType(OutlinedButton), findsNothing);
        expect(find.byType(IconButton), findsNothing);
      },
    );

    testWidgets('nunca sincronizado e sem registros', (tester) async {
      painelCom(const SituacaoDaSincronizacao(registros: []));

      await abrirTela(tester);

      expect(
        find.text('Ainda não sincronizado neste aparelho'),
        findsOneWidget,
      );
      expect(find.text('Nenhum registro pendente de envio'), findsOneWidget);
      expect(
        find.text('Nenhum registro feito neste aparelho ainda.'),
        findsOneWidget,
      );
    });

    testWidgets('plural no contador de pendentes', (tester) async {
      painelCom(
        SituacaoDaSincronizacao(
          registros: [
            registro('s-1', SituacaoDoRegistro.pendente),
            registro('s-2', SituacaoDoRegistro.pendente),
          ],
        ),
      );

      await abrirTela(tester);

      expect(find.text('2 registros pendentes de envio'), findsOneWidget);
    });

    testWidgets('"Sincronizar agora" sincroniza e atualiza a lista', (
      tester,
    ) async {
      painelCom(
        SituacaoDaSincronizacao(
          registros: [registro('s-1', SituacaoDoRegistro.pendente)],
        ),
      );
      when(painel.sincronizarAgora).thenAnswer((_) async {
        when(painel.carregar).thenAnswer(
          (_) async => SituacaoDaSincronizacao(
            registros: [registro('s-1', SituacaoDoRegistro.enviado)],
            ultimaSincronizacao: DateTime(2026, 10, 21, 11),
          ),
        );
        return true;
      });
      await abrirTela(tester);

      await tester.tap(find.text('Sincronizar agora'));
      await tester.pumpAndSettle();

      verify(painel.sincronizarAgora).called(1);
      expect(find.text('Enviado'), findsOneWidget);
      expect(find.text('Pendente'), findsNothing);
      expect(find.text('Nenhum registro pendente de envio'), findsOneWidget);
    });

    testWidgets('sem rede mostra o aviso e o registro segue pendente', (
      tester,
    ) async {
      painelCom(
        SituacaoDaSincronizacao(
          registros: [registro('s-1', SituacaoDoRegistro.pendente)],
        ),
      );
      when(painel.sincronizarAgora).thenAnswer((_) async => false);
      await abrirTela(tester);

      await tester.tap(find.text('Sincronizar agora'));
      await tester.pumpAndSettle();

      expect(find.text(SincronizacaoCubit.avisoSemSincronizar), findsOneWidget);
      expect(find.text('Pendente'), findsOneWidget);
    });

    testWidgets('botão fica desligado enquanto sincroniza', (tester) async {
      painelCom(const SituacaoDaSincronizacao(registros: []));
      final espera = Completer<bool>();
      when(painel.sincronizarAgora).thenAnswer((_) => espera.future);
      await abrirTela(tester);

      await tester.tap(find.text('Sincronizar agora'));
      await tester.pump();

      expect(find.text('Sincronizando…'), findsOneWidget);
      final botao = tester.widget<FilledButton>(find.bySubtype<FilledButton>());
      expect(botao.onPressed, isNull);

      espera.complete(true);
      await tester.pumpAndSettle();
      expect(find.text('Sincronizar agora'), findsOneWidget);
    });

    testWidgets('erro de carregamento mostra mensagem amigável', (
      tester,
    ) async {
      painelCom(const SituacaoDaSincronizacao(registros: []));
      when(painel.carregar).thenThrow(StateError('banco fechado'));

      await abrirTela(tester);

      expect(
        find.text('Não foi possível carregar os dados. Tente novamente.'),
        findsOneWidget,
      );
    });
  });

  group('ResumoDaSincronizacao', () {
    Widget faixa(Widget filho) => MaterialApp(home: Scaffold(body: filho));

    testWidgets('mostra o contador, a última sincronização e o botão', (
      tester,
    ) async {
      painelCom(
        SituacaoDaSincronizacao(
          registros: [registro('s-1', SituacaoDoRegistro.pendente)],
          ultimaSincronizacao: DateTime(2026, 10, 21, 10, 5),
        ),
      );

      await tester.pumpWidget(
        faixa(
          ResumoDaSincronizacao(criarCubit: () => SincronizacaoCubit(painel)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 registro pendente de envio'), findsOneWidget);
      expect(
        find.text('Última sincronização: 21/10/2026 às 10:05'),
        findsOneWidget,
      );
      expect(find.text('Sincronizar agora'), findsOneWidget);
    });

    testWidgets('tocar na faixa abre a lista de registros', (tester) async {
      painelCom(
        SituacaoDaSincronizacao(
          registros: [registro('s-1', SituacaoDoRegistro.pendente)],
        ),
      );
      await tester.pumpWidget(
        faixa(
          ResumoDaSincronizacao(criarCubit: () => SincronizacaoCubit(painel)),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('1 registro pendente de envio'));
      await tester.pumpAndSettle();

      expect(find.byType(SincronizacaoScreen), findsOneWidget);
      expect(find.text('Córrego Gasparinho'), findsOneWidget);
    });

    testWidgets('sem o núcleo offline aberto não mostra nada', (tester) async {
      await tester.pumpWidget(faixa(const ResumoDaSincronizacao()));
      await tester.pumpAndSettle();

      expect(find.text('Sincronizar agora'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
