import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/core/aplicador.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/core/aplicador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/admin_ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/criar_ponto_de_aplicacao_cubit.dart';
import 'package:geoprag_modules/src/entities/usuario.dart';
import 'package:geoprag_modules/src/state/acao_feedback.dart';
import 'package:geoprag_modules/src/widgets/base_form_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../gestao_de_aplicacoes_fixtures.dart';

class MockAdminPontoDeAplicacaoRepository extends Mock
    implements AdminPontoDeAplicacaoRepository {}

class MockAplicadorRepository extends Mock implements AplicadorRepository {}

void main() {
  late MockAdminPontoDeAplicacaoRepository repository;
  late MockAplicadorRepository aplicadorRepository;
  late CriarPontoDeAplicacaoCubit cubit;

  final aplicador = Aplicador(
    id: '1',
    nome: 'João Silva',
    status: UsuarioStatus.ativo,
    dataCriacao: DateTime(2026, 5, 10),
    email: 'joao.silva@email.com',
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

  Widget wrap() => MaterialApp(
    home: Scaffold(
      body: BlocProvider<CriarPontoDeAplicacaoCubit>.value(
        value: cubit,
        child: const BaseFormScreen<CriarPontoDeAplicacaoCubit>(),
      ),
    ),
  );

  setUp(() {
    repository = MockAdminPontoDeAplicacaoRepository();
    aplicadorRepository = MockAplicadorRepository();
    when(
      () => aplicadorRepository.listar(),
    ).thenAnswer((_) async => [aplicador]);
    registerFallbackValue(pontoDeAplicacao());
  });

  Future<void> montar(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    cubit = CriarPontoDeAplicacaoCubit(repository, aplicadorRepository);
    await tester.pumpWidget(wrap());
    await tester.pump();
  }

  /// Preenche os campos na ordem em que o Cubit os monta.
  Future<void> preencher(WidgetTester tester) async {
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Córrego Novo');
    await tester.enterText(campos.at(1), 'Gasparinho');
    await tester.enterText(campos.at(2), 'Rua Nova');
    await tester.enterText(campos.at(3), '240');
    await tester.enterText(campos.at(4), 'Trecho de 100 m.');
    await tester.enterText(campos.at(5), '2');
    await tester.enterText(campos.at(6), '0,5');
    await tester.enterText(campos.at(7), '0,4');
    await tester.enterText(campos.at(8), '120');
    await tester.enterText(campos.at(9), '50');
    await tester.enterText(campos.at(10), '4');
    await tester.pump();
  }

  testWidgets('a vazão só aparece depois dos três parâmetros hidrológicos',
      (tester) async {
    await montar(tester);

    expect(cubit.vazaoPrevia, isNull);

    await preencher(tester);

    expect(cubit.vazaoPrevia, closeTo(0.4, 0.0001));
    expect(find.text('0.400 m³/s'), findsOneWidget);
  });

  testWidgets('não envia enquanto um campo obrigatório está vazio',
      (tester) async {
    await montar(tester);

    final enviou = await cubit.submit();

    expect(enviou, isFalse);
    verifyNever(
      () => repository.criar(
        nome: any(named: 'nome'),
        bairro: any(named: 'bairro'),
        endereco: any(named: 'endereco'),
        numeroReferencia: any(named: 'numeroReferencia'),
        descricaoDoTrecho: any(named: 'descricaoDoTrecho'),
        larguraMetros: any(named: 'larguraMetros'),
        profundidadeMetros: any(named: 'profundidadeMetros'),
        velocidadeMetrosPorSegundo: any(named: 'velocidadeMetrosPorSegundo'),
        dosagemMl: any(named: 'dosagemMl'),
        distanciaEntreSubpontosMetros: any(
          named: 'distanciaEntreSubpontosMetros',
        ),
        quantidadeDeSubpontos: any(named: 'quantidadeDeSubpontos'),
        aplicadorId: any(named: 'aplicadorId'),
      ),
    );
  });

  testWidgets('sem aplicador escolhido, cadastra o ponto sem responsável',
      (tester) async {
    when(
      () => repository.criar(
        nome: any(named: 'nome'),
        bairro: any(named: 'bairro'),
        endereco: any(named: 'endereco'),
        numeroReferencia: any(named: 'numeroReferencia'),
        descricaoDoTrecho: any(named: 'descricaoDoTrecho'),
        larguraMetros: any(named: 'larguraMetros'),
        profundidadeMetros: any(named: 'profundidadeMetros'),
        velocidadeMetrosPorSegundo: any(named: 'velocidadeMetrosPorSegundo'),
        dosagemMl: any(named: 'dosagemMl'),
        distanciaEntreSubpontosMetros: any(
          named: 'distanciaEntreSubpontosMetros',
        ),
        quantidadeDeSubpontos: any(named: 'quantidadeDeSubpontos'),
        aplicadorId: any(named: 'aplicadorId'),
      ),
    ).thenAnswer((_) async => pontoDeAplicacao());

    await montar(tester);
    await preencher(tester);
    await cubit.submit();

    final chamada = verify(
      () => repository.criar(
        nome: 'Córrego Novo',
        bairro: 'Gasparinho',
        endereco: 'Rua Nova',
        numeroReferencia: '240',
        descricaoDoTrecho: 'Trecho de 100 m.',
        larguraMetros: 2,
        profundidadeMetros: 0.5,
        velocidadeMetrosPorSegundo: 0.4,
        dosagemMl: 120,
        distanciaEntreSubpontosMetros: 50,
        quantidadeDeSubpontos: 4,
        aplicadorId: captureAny(named: 'aplicadorId'),
      ),
    )..called(1);

    expect(chamada.captured.single, isNull);
    expect(cubit.state.feedback, isA<AcaoFeedbackSucesso>());
  });

  testWidgets('falha do repositório vira feedback de erro na própria tela',
      (tester) async {
    when(
      () => repository.criar(
        nome: any(named: 'nome'),
        bairro: any(named: 'bairro'),
        endereco: any(named: 'endereco'),
        numeroReferencia: any(named: 'numeroReferencia'),
        descricaoDoTrecho: any(named: 'descricaoDoTrecho'),
        larguraMetros: any(named: 'larguraMetros'),
        profundidadeMetros: any(named: 'profundidadeMetros'),
        velocidadeMetrosPorSegundo: any(named: 'velocidadeMetrosPorSegundo'),
        dosagemMl: any(named: 'dosagemMl'),
        distanciaEntreSubpontosMetros: any(
          named: 'distanciaEntreSubpontosMetros',
        ),
        quantidadeDeSubpontos: any(named: 'quantidadeDeSubpontos'),
        aplicadorId: any(named: 'aplicadorId'),
      ),
    ).thenAnswer((_) async => throw Exception('offline'));

    await montar(tester);
    await preencher(tester);
    await cubit.submit();

    final feedback = cubit.state.feedback;
    expect(feedback, isA<AcaoFeedbackErro>());
    expect(feedback!.mensagem, isNot(contains('Exception')));
  });
}
