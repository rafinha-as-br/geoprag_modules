import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/solicitacao_redefinicao.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/solicitacao_redefinicao_repository.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/aguardando_autorizacao_screen.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/autorizacao_redefinicao_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminNavigator extends Mock implements AdminNavigator {}

class MockSolicitacaoRedefinicaoRepository extends Mock
    implements SolicitacaoRedefinicaoRepository {}

void main() {
  late MockAdminNavigator navigator;
  late MockSolicitacaoRedefinicaoRepository repository;

  const solicitacao = SolicitacaoRedefinicao(
    id: 'sr1',
    nomeSolicitante: 'Célia Ramos',
    cargo: 'Sub-Administrador',
    status: StatusSolicitacaoRedefinicao.aguardando,
  );

  setUp(() {
    navigator = MockAdminNavigator();
    repository = MockSolicitacaoRedefinicaoRepository();
  });

  Widget wrap() {
    return MaterialApp(
      home: AdminNavigatorScope(
        navigator: navigator,
        child: BlocProvider(
          create: (_) => AutorizacaoRedefinicaoCubit(repository),
          child: const AguardandoAutorizacaoScreen(),
        ),
      ),
    );
  }

  testWidgets(
    'reflete status "aguardando": mostra hourglass e aciona os atalhos de navegação',
    (tester) async {
      when(
        () => repository.buscarPendente(),
      ).thenAnswer((_) async => solicitacao);

      await tester.pumpWidget(wrap());
      await tester.pump();

      expect(find.text('Aguardando autorização'), findsOneWidget);

      await tester.tap(
        find.text('Ver painel do Administrador principal'),
      );
      verify(() => navigator.toAutorizarRedefinicao()).called(1);

      await tester.tap(find.text('Cancelar solicitação'));
      verify(() => navigator.back()).called(1);
    },
  );

  testWidgets(
    'reflete status "autorizado": mostra confirmação e navega para verificar código',
    (tester) async {
      when(() => repository.buscarPendente()).thenAnswer(
        (_) async =>
            solicitacao.copyWith(status: StatusSolicitacaoRedefinicao.autorizado),
      );

      await tester.pumpWidget(wrap());
      await tester.pump();

      expect(find.text('Autorização concedida'), findsOneWidget);

      await tester.tap(find.text('Continuar'));
      verify(() => navigator.toVerificarCodigoSubAdmin()).called(1);
    },
  );

  testWidgets('reflete status "negado": mostra mensagem de negação', (
    tester,
  ) async {
    when(() => repository.buscarPendente()).thenAnswer(
      (_) async =>
          solicitacao.copyWith(status: StatusSolicitacaoRedefinicao.negado),
    );

    await tester.pumpWidget(wrap());
    await tester.pump();

    expect(find.text('Solicitação negada'), findsOneWidget);

    await tester.tap(find.text('Voltar ao login'));
    verify(() => navigator.back()).called(1);
  });
}
