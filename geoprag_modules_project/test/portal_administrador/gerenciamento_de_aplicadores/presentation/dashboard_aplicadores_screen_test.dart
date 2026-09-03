import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/core/aplicador.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/core/aplicador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/presentation/aplicadores_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/presentation/dashboard_aplicadores_screen.dart';
import 'package:geoprag_modules/src/entities/usuario.dart';
import 'package:mocktail/mocktail.dart';

class MockAplicadorRepository extends Mock implements AplicadorRepository {}

class MockAdminNavigator extends Mock implements AdminNavigator {}

void main() {
  Aplicador aplicador(String id, String nome) => Aplicador(
    id: id,
    nome: nome,
    status: UsuarioStatus.ativo,
    dataCriacao: DateTime(2026, 5, 10),
    email: '$id@email.com',
    cpf: '111.111.111-11',
    dataNascimento: DateTime(1988, 4, 12),
    sexo: 'Masculino',
    telefone: '(47) 99111-1111',
    cep: '89010-000',
    rua: 'Rua das Flores',
    numero: '50',
    bairro: 'Belchior',
    cidade: 'Blumenau',
    uf: 'SC',
  );

  Future<void> pumpScreen(
    WidgetTester tester,
    MockAplicadorRepository repository,
  ) async {
    final navigator = MockAdminNavigator();
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: AdminNavigatorScope(
          navigator: navigator,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => AdminSessionCubit()),
              BlocProvider(create: (_) => AplicadoresCubit(repository)),
            ],
            child: const DashboardAplicadoresScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('busca filtra por nome combinando com o filtro de chips', (
    tester,
  ) async {
    final repository = MockAplicadorRepository();
    when(
      () => repository.listar(),
    ).thenAnswer((_) async => [aplicador('1', 'João Silva'), aplicador('2', 'Maria Souza')]);

    await pumpScreen(tester, repository);

    expect(find.text('João Silva'), findsOneWidget);
    expect(find.text('Maria Souza'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'maria');
    await tester.pump();

    expect(find.text('João Silva'), findsNothing);
    expect(find.text('Maria Souza'), findsOneWidget);
  });

  testWidgets('mostra o empty-state quando a busca não encontra ninguém', (
    tester,
  ) async {
    final repository = MockAplicadorRepository();
    when(
      () => repository.listar(),
    ).thenAnswer((_) async => [aplicador('1', 'João Silva')]);

    await pumpScreen(tester, repository);

    await tester.enterText(find.byType(TextField), 'inexistente');
    await tester.pump();

    expect(find.text('Nenhum aplicador encontrado.'), findsOneWidget);
  });

  testWidgets(
    'rola sem overflow quando a listagem tem muitos aplicadores em viewport pequeno',
    (tester) async {
      // GEOPRAG-129: nem o body da tela nem GeopragDataTable tinham scroll
      // próprio — uma lista longa em viewport pequeno estourava o layout em
      // vez de rolar.
      final repository = MockAplicadorRepository();
      when(() => repository.listar()).thenAnswer(
        (_) async => [
          for (var i = 1; i <= 30; i++) aplicador('$i', 'Aplicador $i'),
        ],
      );

      final navigator = MockAdminNavigator();
      await tester.binding.setSurfaceSize(const Size(1400, 500));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: AdminNavigatorScope(
            navigator: navigator,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => AdminSessionCubit()),
                BlocProvider(create: (_) => AplicadoresCubit(repository)),
              ],
              child: const DashboardAplicadoresScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -2000),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Aplicador 30'), findsOneWidget);
    },
  );
}
