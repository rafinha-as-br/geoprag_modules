import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/aplicador_resumo.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/aplicador_resumo_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/admin_ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/ponto_de_aplicacao_detalhe_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/ponto_de_aplicacao_detalhe_state.dart';
import 'package:geoprag_modules/src/api/api_exceptions.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/src/entities/usuario.dart';
import 'package:geoprag_modules/src/errors/app_error_messages.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:geoprag_modules/src/state/acao_feedback.dart';
import 'package:mocktail/mocktail.dart';

import '../gestao_de_aplicacoes_fixtures.dart';

class MockAdminPontoDeAplicacaoRepository extends Mock
    implements AdminPontoDeAplicacaoRepository {}

class MockAplicadorRepository extends Mock implements AplicadorResumoRepository {}

void main() {
  late MockAdminPontoDeAplicacaoRepository repository;
  late MockAplicadorRepository aplicadorRepository;

  const aplicador = AplicadorResumo(
    id: '1',
    nome: 'João Silva',
    status: UsuarioStatus.ativo,
  );

  setUp(() {
    repository = MockAdminPontoDeAplicacaoRepository();
    when(() => repository.idsDePontosEmAtraso()).thenAnswer((_) async => {});
    aplicadorRepository = MockAplicadorRepository();
  });

  Future<PontoDeAplicacaoDetalheCubit> carregar(PontoDeAplicacao ponto) async {
    when(() => repository.buscarPorId('pa1')).thenAnswer((_) async => ponto);
    when(
      () => aplicadorRepository.listar(),
    ).thenAnswer((_) async => [aplicador]);
    final cubit = PontoDeAplicacaoDetalheCubit(
      repository,
      aplicadorRepository,
      'pa1',
    );
    await Future<void>.delayed(Duration.zero);
    return cubit;
  }

  test('carrega o ponto com a vazão derivada dos parâmetros brutos', () async {
    final cubit = await carregar(
      pontoDeAplicacao(
        larguraMetros: 2,
        profundidadeMetros: 0.5,
        velocidadeMetrosPorSegundo: 0.4,
      ),
    );

    final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
    expect(state.ponto.vazao, closeTo(0.4, 0.0001));
  });

  test('o ponto em atraso chega ao detalhe marcado como em atraso', () async {
    when(
      () => repository.idsDePontosEmAtraso(),
    ).thenAnswer((_) async => {'pa1'});
    final cubit = await carregar(pontoDeAplicacao());

    final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
    expect(state.ponto.emAtraso, isTrue);
  });

  test('removerAlertaDeAtraso chama o repositório, recarrega e dá feedback',
      () async {
    when(
      () => repository.idsDePontosEmAtraso(),
    ).thenAnswer((_) async => {'pa1'});
    when(() => repository.removerAlertaDeAtraso('pa1')).thenAnswer((_) async {
      when(() => repository.idsDePontosEmAtraso()).thenAnswer((_) async => {});
    });
    final cubit = await carregar(pontoDeAplicacao());

    await cubit.removerAlertaDeAtraso();

    verify(() => repository.removerAlertaDeAtraso('pa1')).called(1);
    final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
    expect(state.ponto.emAtraso, isFalse);
    expect(state.feedback, isA<AcaoFeedbackSucesso>());
  });

  test('removerAlertaDeAtraso rejeitado vira feedback de erro amigável',
      () async {
    when(() => repository.removerAlertaDeAtraso('pa1')).thenThrow(
      const OperacaoNaoPermitidaException('Este ponto não está em atraso.'),
    );
    final cubit = await carregar(pontoDeAplicacao());

    await cubit.removerAlertaDeAtraso();

    final feedback = (cubit.state as PontoDeAplicacaoDetalheLoaded).feedback;
    expect(feedback, isA<AcaoFeedbackErro>());
  });

  test('resolve o nome do aplicador quando o ponto está direcionado', () async {
    final cubit = await carregar(
      pontoDeAplicacao(
        estado: EstadoPontoDeAplicacao.direcionada,
        aplicadorId: '1',
      ),
    );

    final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
    expect(state.ponto.aplicadorNome, 'João Silva');
  });

  test('não consulta aplicador nenhum quando o ponto não foi direcionado',
      () async {
    final cubit = await carregar(pontoDeAplicacao());

    final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
    expect(state.ponto.aplicadorNome, isNull);
    verifyNever(() => aplicadorRepository.listar());
  });

  test('aplicador vinculado que sumiu do cadastro não derruba a tela do ponto',
      () async {
    when(() => repository.buscarPorId('pa1')).thenAnswer(
      (_) async => pontoDeAplicacao(
        estado: EstadoPontoDeAplicacao.direcionada,
        aplicadorId: '9',
      ),
    );
    when(
      () => aplicadorRepository.listar(),
    ).thenAnswer((_) async => [aplicador]);

    final cubit = PontoDeAplicacaoDetalheCubit(
      repository,
      aplicadorRepository,
      'pa1',
    );
    await Future<void>.delayed(Duration.zero);

    final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
    expect(state.ponto.id, 'pa1');
    expect(state.ponto.aplicadorNome, isNull);
  });

  test('lista de aplicadores fora do ar não derruba a tela do ponto', () async {
    when(() => repository.buscarPorId('pa1')).thenAnswer(
      (_) async => pontoDeAplicacao(
        estado: EstadoPontoDeAplicacao.direcionada,
        aplicadorId: '1',
      ),
    );
    when(() => aplicadorRepository.listar()).thenAnswer(
      (_) async => throw const FalhaDeConexaoException('Sem conexão.'),
    );

    final cubit = PontoDeAplicacaoDetalheCubit(
      repository,
      aplicadorRepository,
      'pa1',
    );
    await Future<void>.delayed(Duration.zero);

    final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
    expect(state.ponto.aplicadorNome, isNull);
  });

  test('erro do servidor ao carregar mostra a mensagem amigável', () async {
    when(() => repository.buscarPorId('pa1')).thenAnswer(
      (_) async => throw const ErroDoServidorException(
        'O servidor encontrou um problema.',
        status: 503,
      ),
    );

    final cubit = PontoDeAplicacaoDetalheCubit(
      repository,
      aplicadorRepository,
      'pa1',
    );
    await Future<void>.delayed(Duration.zero);

    final state = cubit.state as PontoDeAplicacaoDetalheError;
    expect(state.message, 'O servidor encontrou um problema.');
  });

  test('mostra a mensagem de negócio quando o ponto não existe', () async {
    when(() => repository.buscarPorId('pa1')).thenAnswer(
      (_) async => throw const EntidadeNaoEncontradaException(
        'Ponto de aplicação "pa1" não encontrado.',
      ),
    );

    final cubit = PontoDeAplicacaoDetalheCubit(
      repository,
      aplicadorRepository,
      'pa1',
    );
    await Future<void>.delayed(Duration.zero);

    expect(
      (cubit.state as PontoDeAplicacaoDetalheError).message,
      'Ponto de aplicação "pa1" não encontrado.',
    );
  });

  test('erro inesperado vira mensagem genérica, sem vazar a exceção bruta',
      () async {
    when(
      () => repository.buscarPorId('pa1'),
    ).thenAnswer((_) async => throw Exception('offline'));

    final cubit = PontoDeAplicacaoDetalheCubit(
      repository,
      aplicadorRepository,
      'pa1',
    );
    await Future<void>.delayed(Duration.zero);

    final state = cubit.state as PontoDeAplicacaoDetalheError;
    expect(state.message, isNot(contains('Exception')));
  });

  group('ações individuais (GEOPRAG-110)', () {
    final agendamento = Agendamento.gerar(
      dataInicio: DateTime(2026, 9, 10),
      intervaloDias: 15,
      quantidadeRecorrencias: 1,
    );

    test('ativar chama o repository e recarrega com feedback de sucesso',
        () async {
      final cubit = await carregar(
        pontoDeAplicacao(estado: EstadoPontoDeAplicacao.direcionada, aplicadorId: '1'),
      );
      when(() => repository.ativar('pa1', agendamento)).thenAnswer((_) async {});
      when(() => repository.buscarPorId('pa1')).thenAnswer(
        (_) async => pontoDeAplicacao(
          estado: EstadoPontoDeAplicacao.ativa,
          aplicadorId: '1',
          agendamento: agendamento,
        ),
      );

      await cubit.ativar(agendamento);

      final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
      expect(state.ponto.estado, EstadoPontoDeAplicacao.ativa);
      expect(state.feedback, isA<AcaoFeedbackSucesso>());
      expect(state.processando, isFalse);
      verify(() => repository.ativar('pa1', agendamento)).called(1);
    });

    test('rejeição de domínio vira feedback de erro amigável, sem recarregar',
        () async {
      final cubit = await carregar(pontoDeAplicacao());
      when(() => repository.ativar('pa1', agendamento)).thenAnswer(
        (_) async => throw const OperacaoNaoPermitidaException(
          'Não é possível ativar este ponto.',
        ),
      );

      await cubit.ativar(agendamento);

      final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
      expect(state.feedback, isA<AcaoFeedbackErro>());
      expect(
        (state.feedback as AcaoFeedbackErro).mensagem,
        'Não é possível ativar este ponto.',
      );
      expect(state.processando, isFalse);
      // O ponto exibido continua o original — a ação falhou, não houve
      // `buscarPorId` de recarregamento.
      expect(state.ponto.estado, EstadoPontoDeAplicacao.enderecada);
    });

    test('desativar chama o repository e recarrega', () async {
      final cubit = await carregar(
        pontoDeAplicacao(estado: EstadoPontoDeAplicacao.ativa, aplicadorId: '1'),
      );
      when(() => repository.desativar('pa1')).thenAnswer((_) async {});
      when(() => repository.buscarPorId('pa1')).thenAnswer(
        (_) async => pontoDeAplicacao(
          estado: EstadoPontoDeAplicacao.desativado,
          aplicadorId: '1',
        ),
      );

      await cubit.desativar();

      final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
      expect(state.ponto.estado, EstadoPontoDeAplicacao.desativado);
      expect(state.feedback, isA<AcaoFeedbackSucesso>());
    });

    test('reativar chama o repository e recarrega', () async {
      final cubit = await carregar(
        pontoDeAplicacao(estado: EstadoPontoDeAplicacao.desativado, aplicadorId: '1'),
      );
      when(() => repository.reativar('pa1')).thenAnswer((_) async {});
      when(() => repository.buscarPorId('pa1')).thenAnswer(
        (_) async => pontoDeAplicacao(
          estado: EstadoPontoDeAplicacao.ativa,
          aplicadorId: '1',
        ),
      );

      await cubit.reativar();

      final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
      expect(state.ponto.estado, EstadoPontoDeAplicacao.ativa);
      expect(state.feedback, isA<AcaoFeedbackSucesso>());
    });

    test('atribuirAplicador chama o repository e recarrega', () async {
      final cubit = await carregar(pontoDeAplicacao());
      when(() => repository.atribuirAplicador('pa1', '1')).thenAnswer((_) async {});
      when(() => repository.buscarPorId('pa1')).thenAnswer(
        (_) async => pontoDeAplicacao(
          estado: EstadoPontoDeAplicacao.direcionada,
          aplicadorId: '1',
        ),
      );

      await cubit.atribuirAplicador('1');

      final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
      expect(state.ponto.aplicadorNome, 'João Silva');
      expect(state.feedback, isA<AcaoFeedbackSucesso>());
    });

    test('desatribuirAplicador chama o repository e recarrega', () async {
      final cubit = await carregar(
        pontoDeAplicacao(estado: EstadoPontoDeAplicacao.direcionada, aplicadorId: '1'),
      );
      when(() => repository.desatribuirAplicador('pa1')).thenAnswer((_) async {});
      when(() => repository.buscarPorId('pa1')).thenAnswer(
        (_) async => pontoDeAplicacao(),
      );

      await cubit.desatribuirAplicador();

      final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
      expect(state.ponto.aplicadorNome, isNull);
      expect(state.feedback, isA<AcaoFeedbackSucesso>());
    });

    test('listarAplicadoresParaAtribuir cruza aplicadores e contagem de pontos',
        () async {
      final cubit = await carregar(pontoDeAplicacao());
      when(() => aplicadorRepository.listar()).thenAnswer((_) async => [aplicador]);
      when(() => repository.listar()).thenAnswer(
        (_) async => [
          pontoDeAplicacao(id: 'pa1', aplicadorId: '1'),
          pontoDeAplicacao(id: 'pa2', aplicadorId: '1'),
          pontoDeAplicacao(id: 'pa3'),
        ],
      );

      final opcoes = await cubit.listarAplicadoresParaAtribuir();

      expect(opcoes, hasLength(1));
      expect(opcoes!.single.id, '1');
      expect(opcoes.single.quantidadePontosAtribuidos, 2);
    });

    test('listarAplicadoresParaAtribuir deixa de fora o aplicador desativado',
        () async {
      final cubit = await carregar(pontoDeAplicacao());
      when(() => aplicadorRepository.listar()).thenAnswer(
        (_) async => [
          aplicador,
          const AplicadorResumo(
            id: '2',
            nome: 'Maria Souza',
            status: UsuarioStatus.desativado,
          ),
        ],
      );
      when(() => repository.listar()).thenAnswer((_) async => []);

      final opcoes = await cubit.listarAplicadoresParaAtribuir();

      expect(opcoes!.map((o) => o.id), ['1']);
    });

    test('listarAplicadoresParaAtribuir sem a lista: devolve null e avisa',
        () async {
      final cubit = await carregar(pontoDeAplicacao());
      when(() => aplicadorRepository.listar()).thenAnswer(
        (_) async => throw const FalhaDeConexaoException(
          'Sem conexão com o servidor.',
        ),
      );
      when(() => repository.listar()).thenAnswer((_) async => []);

      final opcoes = await cubit.listarAplicadoresParaAtribuir();

      expect(opcoes, isNull);
      final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
      expect(
        (state.feedback as AcaoFeedbackErro).mensagem,
        'Sem conexão com o servidor.',
      );
    });

    test('erro de validação (422) do servidor chega como feedback amigável',
        () async {
      final cubit = await carregar(
        pontoDeAplicacao(estado: EstadoPontoDeAplicacao.direcionada, aplicadorId: '1'),
      );
      when(() => repository.ativar('pa1', agendamento)).thenAnswer(
        (_) async => throw const RequisicaoInvalidaException(
          'A data da primeira aplicação não pode estar no passado.',
          status: 422,
        ),
      );

      await cubit.ativar(agendamento);

      final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
      expect(
        (state.feedback as AcaoFeedbackErro).mensagem,
        'A data da primeira aplicação não pode estar no passado.',
      );
      expect(state.processando, isFalse);
    });

    test('conflito (409) ao atribuir chega como feedback amigável', () async {
      final cubit = await carregar(pontoDeAplicacao());
      when(() => repository.atribuirAplicador('pa1', '1')).thenAnswer(
        (_) async => throw const OperacaoNaoPermitidaException(
          'O aplicador está desativado e não pode ser atribuído a um ponto.',
        ),
      );

      await cubit.atribuirAplicador('1');

      final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
      expect(
        (state.feedback as AcaoFeedbackErro).mensagem,
        'O aplicador está desativado e não pode ser atribuído a um ponto.',
      );
    });

    test(
        'ação feita no servidor mas releitura falhou: mantém a tela e avisa, '
        'em vez de trocar por erro de carregamento', () async {
      final cubit = await carregar(pontoDeAplicacao());
      when(() => repository.atribuirAplicador('pa1', '1')).thenAnswer((_) async {});
      when(() => repository.buscarPorId('pa1')).thenAnswer(
        (_) async => throw const FalhaDeConexaoException(
          'Sem conexão com o servidor.',
        ),
      );

      await cubit.atribuirAplicador('1');

      final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
      expect(state.processando, isFalse);
      expect(
        (state.feedback as AcaoFeedbackErro).mensagem,
        AppErrorMessages.acaoFeitaSemAtualizarATela,
      );
    });

    test('servidor fora do ar durante a ação vira feedback, não exceção',
        () async {
      final cubit = await carregar(pontoDeAplicacao());
      when(() => repository.atribuirAplicador('pa1', '1')).thenAnswer(
        (_) async => throw const FalhaDeConexaoException(
          'Sem conexão com o servidor.',
        ),
      );

      await cubit.atribuirAplicador('1');

      final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
      expect(
        (state.feedback as AcaoFeedbackErro).mensagem,
        'Sem conexão com o servidor.',
      );
      expect(state.processando, isFalse);
    });
  });
}
