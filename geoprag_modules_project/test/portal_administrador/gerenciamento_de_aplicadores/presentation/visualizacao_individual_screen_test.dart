import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/core/aplicador.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/core/aplicador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/core/atuacao_aplicador.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/presentation/aplicador_detalhe_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/presentation/visualizacao_individual_screen.dart';
import 'package:geoprag_modules/src/entities/usuario.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:mocktail/mocktail.dart';

class MockAplicadorRepository extends Mock implements AplicadorRepository {}

void main() {
  late MockAplicadorRepository repository;

  final aplicador = Aplicador(
    id: '2',
    nome: 'Maria Souza',
    status: UsuarioStatus.ativo,
    dataCriacao: DateTime(2026, 7, 1),
    email: 'maria.souza@email.com',
    cpf: '123.456.789-00',
    dataNascimento: DateTime(1992, 9, 3),
    sexo: 'Feminino',
    telefone: '(47) 99999-9999',
    cep: '89020-000',
    rua: 'Rua Principal',
    numero: '100',
    bairro: 'Poço Grande',
    cidade: 'Blumenau',
    uf: 'SC',
  );

  const historico = [
    AtuacaoAplicador(
      tipo: AtuacaoAplicadorTipo.aplicacao,
      titulo: 'Aplicação Concluída',
      subtitulo: 'Córrego Gasparinho - 20/06/2026',
      valor: '50ml aplicados',
    ),
  ];

  setUp(() {
    repository = MockAplicadorRepository();
  });

  Widget wrap() => MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AdminSessionCubit>(create: (_) => AdminSessionCubit()),
        BlocProvider<AplicadorDetalheCubit>(
          create: (_) => AplicadorDetalheCubit(repository, '2'),
        ),
      ],
      child: const VisualizacaoIndividualScreen(),
    ),
  );

  testWidgets('mostra spinner enquanto o aplicador carrega', (tester) async {
    when(
      () => repository.buscarPorId('2'),
    ).thenAnswer((_) async => aplicador);
    when(
      () => repository.buscarHistorico('2'),
    ).thenAnswer((_) async => historico);

    await tester.pumpWidget(wrap());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('mostra a mensagem de erro amigável quando o carregamento falha', (
    tester,
  ) async {
    when(() => repository.buscarPorId('2')).thenAnswer(
      (_) async => throw const EntidadeNaoEncontradaException(
        'Aplicador "2" não encontrado.',
      ),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível carregar o aplicador: Aplicador "2" não encontrado.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'mostra nome, dados pessoais, histórico e as ações do aplicador carregado',
    (tester) async {
      when(
        () => repository.buscarPorId('2'),
      ).thenAnswer((_) async => aplicador);
      when(
        () => repository.buscarHistorico('2'),
      ).thenAnswer((_) async => historico);

      // Conteúdo em duas colunas não cabe no viewport padrão de teste.
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.text('Maria Souza'), findsOneWidget);
      expect(find.text('Aplicação Concluída'), findsOneWidget);
      expect(find.text('Editar Cadastro'), findsOneWidget);
      expect(find.text('Desativar Cadastro'), findsOneWidget);

      // GEOPRAG-127: CPF fica oculto por padrão (só início/fim visíveis) e
      // só aparece por completo depois de tocar no botão de exibir.
      expect(find.text('123.456.789-00'), findsNothing);
      expect(find.text('123•••••••••00'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();

      expect(find.text('123.456.789-00'), findsOneWidget);
      expect(find.text('123•••••••••00'), findsNothing);
    },
  );
}
