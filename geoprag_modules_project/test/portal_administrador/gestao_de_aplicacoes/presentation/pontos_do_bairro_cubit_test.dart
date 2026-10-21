import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/aplicador_resumo.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/aplicador_resumo_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/admin_ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/lote_de_pontos_reconciliacao.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/pontos_do_bairro_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/widgets/batch_reconcile_dialog.dart';
import 'package:geoprag_modules/src/api/api_exceptions.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/src/entities/usuario.dart';
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

  final desativado = pontoDeAplicacao(
    id: 'pa2',
    identificador: '#GAS2',
    nome: 'Córrego Canalizado',
    estado: EstadoPontoDeAplicacao.desativado,
  );

  setUp(() {
    repository = MockAdminPontoDeAplicacaoRepository();
    aplicadorRepository = MockAplicadorRepository();
    when(
      () => aplicadorRepository.listar(),
    ).thenAnswer((_) async => [aplicador]);
  });

  Future<PontosDoBairroCubit> carregar(List<PontoDeAplicacao> pontos) async {
    when(
      () => repository.listarPorBairro('Gasparinho'),
    ).thenAnswer((_) async => pontos);
    final cubit = PontosDoBairroCubit(
      repository,
      aplicadorRepository,
      'Gasparinho',
    );
    await Future<void>.delayed(Duration.zero);
    return cubit;
  }

  test('busca os pontos do bairro recebido e usa o bairro como título',
      () async {
    final cubit = await carregar([pontoDeAplicacao()]);

    expect(cubit.state.title, 'Gasparinho');
    expect(cubit.state.items.single.id, 'pa1');
    verify(() => repository.listarPorBairro('Gasparinho')).called(1);
  });

  test('a tela do bairro mostra também os pontos desativados', () async {
    final cubit = await carregar([pontoDeAplicacao(), desativado]);

    expect(cubit.state.items.map((p) => p.id), ['pa1', 'pa2']);
  });

  test('busca filtra por nome e identificador', () async {
    final cubit = await carregar([pontoDeAplicacao(), desativado]);

    cubit.buscar('canalizado');
    expect(cubit.state.items.map((p) => p.id), ['pa2']);

    cubit.buscar('#GAS1');
    expect(cubit.state.items.map((p) => p.id), ['pa1']);
  });

  test('emite mensagem amigável quando o repositório falha', () async {
    when(
      () => repository.listarPorBairro('Gasparinho'),
    ).thenAnswer((_) async => throw Exception('offline'));

    final cubit = PontosDoBairroCubit(
      repository,
      aplicadorRepository,
      'Gasparinho',
    );
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.errorMessage, isNot(contains('Exception')));
  });

  group('seleção múltipla e ações em lote (GEOPRAG-101)', () {
    test('idDoItem extrai o id do ViewModel', () async {
      final cubit = await carregar([pontoDeAplicacao()]);

      expect(cubit.idDoItem(cubit.state.items.single), 'pa1');
    });

    test('a coluna de seleção e a barra de ações em lote já vêm no model',
        () async {
      final cubit = await carregar([pontoDeAplicacao()]);

      expect(cubit.state.columns.first.label, 'Selecionar');
      expect(cubit.state.batchActionBar, isNotNull);
    });

    test('selecionados reflete idsSelecionados mesmo com busca filtrando',
        () async {
      final cubit = await carregar([pontoDeAplicacao(), desativado]);

      cubit.alternarSelecao(cubit.state.items.first);
      cubit.buscar('canalizado');

      expect(cubit.selecionados.map((p) => p.id), ['pa1']);
    });

    test('reconciliar particiona a seleção pela regra de estados da ação',
        () async {
      final cubit = await carregar([pontoDeAplicacao(), desativado]);

      cubit.alternarSelecaoDeTodosVisiveis();
      final resultado = cubit.reconciliar(AcaoEmLote.desativar);

      expect(resultado.elegiveis.map((p) => p.id), ['pa1']);
      expect(resultado.ignorados.map((p) => p.item.id), ['pa2']);
    });

    test('listarAplicadoresDisponiveis converte o repositório de aplicadores',
        () async {
      final cubit = await carregar([pontoDeAplicacao()]);

      final opcoes = await cubit.listarAplicadoresDisponiveis();

      expect(opcoes, hasLength(1));
      expect(opcoes.single.id, '1');
      expect(opcoes.single.nome, 'João Silva');
    });

    test('listarAplicadoresDisponiveis deixa de fora o aplicador desativado',
        () async {
      final cubit = await carregar([pontoDeAplicacao()]);
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

      final opcoes = await cubit.listarAplicadoresDisponiveis();

      expect(opcoes.map((o) => o.id), ['1']);
    });

    test('erro do servidor ao carregar o bairro mostra a mensagem da API',
        () async {
      when(() => repository.listarPorBairro('Gasparinho')).thenAnswer(
        (_) async => throw const FalhaDeConexaoException(
          'Sem conexão com o servidor.',
        ),
      );

      final cubit = PontosDoBairroCubit(
        repository,
        aplicadorRepository,
        'Gasparinho',
      );
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.errorMessage, 'Sem conexão com o servidor.');
    });

    test('executarUm(ativar) chama repository.ativar com o agendamento',
        () async {
      final cubit = await carregar([pontoDeAplicacao()]);
      final agendamento = Agendamento.gerar(
        dataInicio: DateTime(2026, 9, 10),
        intervaloDias: 15,
        quantidadeRecorrencias: 1,
      );
      when(
        () => repository.ativar('pa1', agendamento),
      ).thenAnswer((_) async {});

      await cubit.executarUm(
        AcaoEmLote.ativar,
        'pa1',
        BatchReconcileConfirmado(agendamento: agendamento),
      );

      verify(() => repository.ativar('pa1', agendamento)).called(1);
    });

    test('executarUm(desativar) chama repository.desativar', () async {
      final cubit = await carregar([pontoDeAplicacao()]);
      when(() => repository.desativar('pa1')).thenAnswer((_) async {});

      await cubit.executarUm(
        AcaoEmLote.desativar,
        'pa1',
        const BatchReconcileConfirmado(),
      );

      verify(() => repository.desativar('pa1')).called(1);
    });

    test(
      'executarUm(atribuirAplicador) chama repository.atribuirAplicador',
      () async {
        final cubit = await carregar([pontoDeAplicacao()]);
        when(
          () => repository.atribuirAplicador('pa1', '1'),
        ).thenAnswer((_) async {});

        await cubit.executarUm(
          AcaoEmLote.atribuirAplicador,
          'pa1',
          const BatchReconcileConfirmado(aplicadorId: '1'),
        );

        verify(() => repository.atribuirAplicador('pa1', '1')).called(1);
      },
    );

    test('recarregarAposLote limpa a seleção e recarrega a listagem',
        () async {
      final cubit = await carregar([pontoDeAplicacao()]);
      cubit.alternarSelecaoDeTodosVisiveis();
      expect(cubit.state.idsSelecionados, isNotEmpty);

      await cubit.recarregarAposLote();

      expect(cubit.state.idsSelecionados, isEmpty);
      verify(() => repository.listarPorBairro('Gasparinho')).called(2);
    });
  });
}
