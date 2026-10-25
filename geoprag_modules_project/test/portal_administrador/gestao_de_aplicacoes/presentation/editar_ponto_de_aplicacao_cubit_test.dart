import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/admin_ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/editar_ponto_de_aplicacao_cubit.dart';
import 'package:geoprag_modules/src/api/api_exceptions.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:geoprag_modules/src/state/acao_feedback.dart';
import 'package:geoprag_modules/src/widgets/geoprag_numero_inteiro_input.dart';
import 'package:geoprag_modules/src/widgets/geoprag_texto_input.dart';
import 'package:mocktail/mocktail.dart';

import '../gestao_de_aplicacoes_fixtures.dart';

class MockAdminPontoDeAplicacaoRepository extends Mock
    implements AdminPontoDeAplicacaoRepository {}

String? _textoDoCampo(EditarPontoDeAplicacaoCubit cubit, String label) {
  final field = cubit.state.fields.firstWhere((f) => f.label == label).field;
  // Os campos são sempre widgets da biblioteca de inputs (GeopragTextoInput /
  // GeopragNumeroDecimalInput / GeopragNumeroInteiroInput) neste Cubit — sem
  // DropdownButtonFormField (atribuir aplicador é ação própria, GEOPRAG-110,
  // não parte do cadastro). Nenhum usa TextEditingController (GEOPRAG-145);
  // o valor carregado é lido via initialValue.
  final valor = (field as dynamic).initialValue;
  return valor?.toString();
}

const _rotuloTolerancia = 'Tolerância de atraso (dias)';

/// Simula a digitação de [valor] no campo de tolerância, pelo mesmo callback
/// que o widget aciona a cada alteração do texto.
void _digitarTolerancia(EditarPontoDeAplicacaoCubit cubit, int valor) {
  final field = cubit.state.fields
      .firstWhere((f) => f.label == _rotuloTolerancia)
      .field;
  (field as GeopragNumeroInteiroInput).onChanged(valor);
}

/// Simula a digitação do nome pelo callback do campo.
void _digitarNome(EditarPontoDeAplicacaoCubit cubit, String valor) {
  final field = cubit.state.fields
      .firstWhere((f) => f.label == 'Nome do ponto')
      .field;
  (field as GeopragTextoInput).onChanged(valor);
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
    'cadastro travado por execução: só o nome e a tolerância ficam habilitados',
    () async {
      final cubit = await carregar(
        pontoDeAplicacao(subpontos: [execucaoDeTeste]),
      );

      expect(_campoHabilitado(cubit, 'Nome do ponto'), isTrue);
      expect(_campoHabilitado(cubit, _rotuloTolerancia), isTrue);
      expect(_campoHabilitado(cubit, 'Bairro'), isFalse);
      expect(_campoHabilitado(cubit, 'Largura do trecho (m)'), isFalse);
    },
  );

  group('tolerância de atraso', () {
    test('carrega a tolerância do ponto no campo (padrão de 4 dias)', () async {
      final cubit = await carregar(pontoDeAplicacao());

      expect(_textoDoCampo(cubit, _rotuloTolerancia), '4');
    });

    test('carrega uma tolerância própria do ponto', () async {
      final cubit = await carregar(pontoDeAplicacao(toleranciaDias: 7));

      expect(_textoDoCampo(cubit, _rotuloTolerancia), '7');
    });

    test('cadastro liberado: o campo está habilitado', () async {
      final cubit = await carregar(pontoDeAplicacao());

      expect(_campoHabilitado(cubit, _rotuloTolerancia), isTrue);
    });
  });

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
          toleranciaDias: any(named: 'toleranciaDias'),
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
          toleranciaDias: any(named: 'toleranciaDias'),
        ),
      ).called(1);
      verifyNever(() => repository.editarNome(any(), any()));
    });

    test('cadastro travado: chama só editarNome, nunca editarCadastroCompleto',
        () async {
      final cubit = await carregar(pontoDeAplicacao(subpontos: [execucaoDeTeste]));
      _digitarNome(cubit, 'Nome novo');
      when(() => repository.editarNome('pa1', any())).thenAnswer((_) async {});

      await cubit.onSubmit();

      expect(cubit.state.feedback, isA<AcaoFeedbackSucesso>());
      verify(() => repository.editarNome('pa1', 'Nome novo')).called(1);
      verifyNever(() => repository.editarTolerancia(any(), any()));
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
          toleranciaDias: any(named: 'toleranciaDias'),
        ),
      );
    });

    test('cadastro liberado: envia a tolerância editada junto do cadastro',
        () async {
      final cubit = await carregar(pontoDeAplicacao(toleranciaDias: 7));
      _digitarTolerancia(cubit, 3);
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
          toleranciaDias: any(named: 'toleranciaDias'),
        ),
      ).thenAnswer((_) async {});

      await cubit.onSubmit();

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
          toleranciaDias: 3,
        ),
      ).called(1);
      verifyNever(() => repository.editarTolerancia(any(), any()));
    });

    test('cadastro travado: tolerância alterada chama editarTolerancia', () async {
      final cubit = await carregar(
        pontoDeAplicacao(subpontos: [execucaoDeTeste]),
      );
      _digitarTolerancia(cubit, 9);
      when(
        () => repository.editarTolerancia('pa1', any()),
      ).thenAnswer((_) async {});

      await cubit.onSubmit();

      expect(cubit.state.feedback, isA<AcaoFeedbackSucesso>());
      verify(() => repository.editarTolerancia('pa1', 9)).called(1);
      // O nome não mudou: não gera evento de "nome_editado" à toa.
      verifyNever(() => repository.editarNome(any(), any()));
    });

    test('cadastro travado: nome e tolerância alterados chamam as duas operações',
        () async {
      final cubit = await carregar(
        pontoDeAplicacao(subpontos: [execucaoDeTeste]),
      );
      _digitarNome(cubit, 'Nome novo');
      _digitarTolerancia(cubit, 9);
      when(() => repository.editarNome('pa1', any())).thenAnswer((_) async {});
      when(
        () => repository.editarTolerancia('pa1', any()),
      ).thenAnswer((_) async {});

      await cubit.onSubmit();

      verify(() => repository.editarNome('pa1', 'Nome novo')).called(1);
      verify(() => repository.editarTolerancia('pa1', 9)).called(1);
    });

    test('cadastro travado: salvar, voltar ao valor original e salvar de novo '
        'grava o valor revertido', () async {
      final cubit = await carregar(
        pontoDeAplicacao(subpontos: [execucaoDeTeste]),
      );
      when(
        () => repository.editarTolerancia('pa1', any()),
      ).thenAnswer((_) async {});

      _digitarTolerancia(cubit, 6);
      await cubit.onSubmit();
      _digitarTolerancia(cubit, 4);
      await cubit.onSubmit();

      verifyInOrder([
        () => repository.editarTolerancia('pa1', 6),
        () => repository.editarTolerancia('pa1', 4),
      ]);
    });

    test('cadastro travado sem nenhuma alteração: não chama operação alguma',
        () async {
      final cubit = await carregar(
        pontoDeAplicacao(subpontos: [execucaoDeTeste]),
      );

      await cubit.onSubmit();

      expect(cubit.state.feedback, isA<AcaoFeedbackSucesso>());
      verifyNever(() => repository.editarNome(any(), any()));
      verifyNever(() => repository.editarTolerancia(any(), any()));
    });

    test('rejeição de domínio da tolerância vira feedback de erro amigável',
        () async {
      final cubit = await carregar(
        pontoDeAplicacao(subpontos: [execucaoDeTeste]),
      );
      _digitarTolerancia(cubit, 9);
      when(() => repository.editarTolerancia('pa1', any())).thenAnswer(
        (_) async => throw const OperacaoNaoPermitidaException(
          'A tolerância de atraso deve ser de pelo menos 1 dia.',
        ),
      );

      await cubit.onSubmit();

      expect(
        (cubit.state.feedback as AcaoFeedbackErro).mensagem,
        'A tolerância de atraso deve ser de pelo menos 1 dia.',
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
          toleranciaDias: any(named: 'toleranciaDias'),
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

    test('erro da API (422) mostra a mensagem do servidor', () async {
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
          toleranciaDias: any(named: 'toleranciaDias'),
        ),
      ).thenAnswer(
        (_) async => throw const RequisicaoInvalidaException(
          'A largura deve ser maior que zero.',
        ),
      );

      await cubit.onSubmit();

      expect(
        (cubit.state.feedback as AcaoFeedbackErro).mensagem,
        'A largura deve ser maior que zero.',
      );
    });
  });
}
