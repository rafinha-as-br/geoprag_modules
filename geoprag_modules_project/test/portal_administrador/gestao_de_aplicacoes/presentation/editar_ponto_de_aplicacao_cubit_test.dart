import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/admin_ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/editar_ponto_de_aplicacao_cubit.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:geoprag_modules/src/state/acao_feedback.dart';
import 'package:mocktail/mocktail.dart';

import '../gestao_de_aplicacoes_fixtures.dart';

class MockAdminPontoDeAplicacaoRepository extends Mock
    implements AdminPontoDeAplicacaoRepository {}

String? _textoDoCampo(EditarPontoDeAplicacaoCubit cubit, String label) {
  final field = cubit.state.fields.firstWhere((f) => f.label == label).field;
  // Os campos são sempre TextFormField neste Cubit — sem DropdownButtonFormField
  // (atribuir aplicador é ação própria, GEOPRAG-110, não parte do cadastro).
  final textFormField = field as dynamic;
  return (textFormField.controller as dynamic).text as String?;
}

bool _campoHabilitado(EditarPontoDeAplicacaoCubit cubit, String label) {
  final field = cubit.state.fields.firstWhere((f) => f.label == label).field;
  return (field as dynamic).enabled as bool? ?? true;
}

void main() {
  late MockAdminPontoDeAplicacaoRepository repository;

  setUp(() {
    repository = MockAdminPontoDeAplicacaoRepository();
  });

  Future<EditarPontoDeAplicacaoCubit> carregar(
    dynamic ponto, {
    String id = 'pa1',
  }) async {
    when(() => repository.buscarPorId(id)).thenAnswer((_) async => ponto);
    final cubit = EditarPontoDeAplicacaoCubit(repository, id);
    await Future<void>.delayed(Duration.zero);
    return cubit;
  }

  test('carrega os dados do ponto nos campos', () async {
    final cubit = await carregar(
      pontoDeAplicacao(nome: 'Córrego X', bairro: 'Belchior'),
    );

    expect(_textoDoCampo(cubit, 'Nome do ponto'), 'Córrego X');
    expect(_textoDoCampo(cubit, 'Bairro'), 'Belchior');
  });

  test('cadastro liberado: todos os campos ficam habilitados', () async {
    final cubit = await carregar(pontoDeAplicacao());

    expect(_campoHabilitado(cubit, 'Nome do ponto'), isTrue);
    expect(_campoHabilitado(cubit, 'Bairro'), isTrue);
    expect(_campoHabilitado(cubit, 'Largura do trecho (m)'), isTrue);
  });

  test(
    'cadastro travado por execução: só o nome fica habilitado',
    () async {
      final cubit = await carregar(
        pontoDeAplicacao(subpontos: [execucaoDeTeste]),
      );

      expect(_campoHabilitado(cubit, 'Nome do ponto'), isTrue);
      expect(_campoHabilitado(cubit, 'Bairro'), isFalse);
      expect(_campoHabilitado(cubit, 'Largura do trecho (m)'), isFalse);
    },
  );

  test('mostra a mensagem de negócio quando o ponto não existe', () async {
    when(() => repository.buscarPorId('pa1')).thenAnswer(
      (_) async => throw const EntidadeNaoEncontradaException(
        'Ponto de aplicação "pa1" não encontrado.',
      ),
    );

    final cubit = EditarPontoDeAplicacaoCubit(repository, 'pa1');
    await Future<void>.delayed(Duration.zero);

    expect(
      (cubit.state.feedback as AcaoFeedbackErro).mensagem,
      'Ponto de aplicação "pa1" não encontrado.',
    );
  });

  group('onSubmit', () {
    test('cadastro liberado: chama editarCadastroCompleto com os campos', () async {
      final cubit = await carregar(pontoDeAplicacao());
      when(
        () => repository.editarCadastroCompleto(
          'pa1',
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
        ),
      ).thenAnswer((_) async {});

      await cubit.onSubmit();

      expect(cubit.state.feedback, isA<AcaoFeedbackSucesso>());
      verify(
        () => repository.editarCadastroCompleto(
          'pa1',
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
        ),
      ).called(1);
      verifyNever(() => repository.editarNome(any(), any()));
    });

    test('cadastro travado: chama só editarNome, nunca editarCadastroCompleto',
        () async {
      final cubit = await carregar(pontoDeAplicacao(subpontos: [execucaoDeTeste]));
      when(() => repository.editarNome('pa1', any())).thenAnswer((_) async {});

      await cubit.onSubmit();

      expect(cubit.state.feedback, isA<AcaoFeedbackSucesso>());
      verify(() => repository.editarNome('pa1', any())).called(1);
      verifyNever(
        () => repository.editarCadastroCompleto(
          any(),
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
        ),
      );
    });

    test('rejeição de domínio vira feedback de erro amigável', () async {
      final cubit = await carregar(pontoDeAplicacao());
      when(
        () => repository.editarCadastroCompleto(
          'pa1',
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
        ),
      ).thenAnswer(
        (_) async => throw const OperacaoNaoPermitidaException('Travado.'),
      );

      await cubit.onSubmit();

      expect(
        (cubit.state.feedback as AcaoFeedbackErro).mensagem,
        'Travado.',
      );
    });
  });
}
