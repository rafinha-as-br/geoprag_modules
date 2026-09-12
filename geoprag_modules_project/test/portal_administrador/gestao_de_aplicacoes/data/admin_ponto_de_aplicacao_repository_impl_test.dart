import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/data/admin_ponto_de_aplicacao_repository_impl.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/data/mock_pontos_de_aplicacao.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';

void main() {
  late AdminPontoDeAplicacaoRepositoryImpl repository;
  late List<PontoDeAplicacao> snapshotOriginal;

  setUp(() {
    repository = AdminPontoDeAplicacaoRepositoryImpl();
    snapshotOriginal = List.of(mockPontosDeAplicacao);
  });

  // A fonte mockada é uma lista global: sem isso, um `criar` (que adiciona)
  // ou um `ativar`/`desativar`/`atribuirAplicador` (que substitui um item
  // existente) vazaria para os demais testes do arquivo.
  tearDown(() {
    mockPontosDeAplicacao
      ..clear()
      ..addAll(snapshotOriginal);
  });

  Future<PontoDeAplicacao> criar({
    String? aplicadorId,
    String bairro = 'Gasparinho',
  }) => repository.criar(
    nome: 'Córrego Novo',
    bairro: bairro,
    endereco: 'Rua Nova',
    numeroReferencia: 'Sem número',
    descricaoDoTrecho: 'Trecho de teste.',
    larguraMetros: 2,
    profundidadeMetros: 0.5,
    velocidadeMetrosPorSegundo: 0.4,
    dosagemMl: 100,
    distanciaEntreSubpontosMetros: 50,
    quantidadeDeSubpontos: 4,
    aplicadorId: aplicadorId,
  );

  test('listarPorBairro devolve só os pontos daquele bairro', () async {
    final pontos = await repository.listarPorBairro('Gasparinho');

    expect(pontos, isNotEmpty);
    expect(pontos.every((ponto) => ponto.bairro == 'Gasparinho'), isTrue);
  });

  test('buscarPorId falha com mensagem amigável quando o id não existe',
      () async {
    expect(
      () => repository.buscarPorId('inexistente'),
      throwsA(isA<EntidadeNaoEncontradaException>()),
    );
  });

  test('ponto criado sem aplicador nasce endereçado', () async {
    final ponto = await criar();

    expect(ponto.estado, EstadoPontoDeAplicacao.enderecada);
    expect(ponto.aplicadorId, isNull);
  });

  test('ponto criado com aplicador nasce direcionado', () async {
    final ponto = await criar(aplicadorId: '1');

    expect(ponto.estado, EstadoPontoDeAplicacao.direcionada);
    expect(ponto.aplicadorId, '1');
  });

  test('ponto criado nunca traz coordenada nem execução', () async {
    final ponto = await criar();

    expect(ponto.subpontos, isEmpty);
    expect(ponto.primeiraExecucao, isNull);
  });

  test('ponto criado entra na listagem do bairro', () async {
    await criar();

    final pontos = await repository.listarPorBairro('Gasparinho');
    expect(pontos.where((ponto) => ponto.nome == 'Córrego Novo'), hasLength(1));
  });

  group('ativar', () {
    test('ativa um ponto direcionado (pa3) com o agendamento informado', () async {
      final agendamento = Agendamento.gerar(
        dataInicio: DateTime(2026, 9, 10),
        intervaloDias: 15,
        quantidadeRecorrencias: 1,
      );

      await repository.ativar('pa3', agendamento);

      final ponto = await repository.buscarPorId('pa3');
      expect(ponto.estado, EstadoPontoDeAplicacao.ativa);
      expect(ponto.agendamento, agendamento);
    });

    test('falha com mensagem amigável quando o id não existe', () {
      expect(
        () => repository.ativar(
          'inexistente',
          Agendamento.gerar(
            dataInicio: DateTime(2026, 9, 10),
            intervaloDias: 15,
            quantidadeRecorrencias: 1,
          ),
        ),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );
    });

    test('propaga a rejeição de domínio ao ativar um ponto endereçado (pa4)', () {
      expect(
        () => repository.ativar(
          'pa4',
          Agendamento.gerar(
            dataInicio: DateTime(2026, 9, 10),
            intervaloDias: 15,
            quantidadeRecorrencias: 1,
          ),
        ),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });
  });

  group('desativar', () {
    test('desativa um ponto ativo (pa2)', () async {
      await repository.desativar('pa2');

      final ponto = await repository.buscarPorId('pa2');
      expect(ponto.estado, EstadoPontoDeAplicacao.desativado);
    });

    test('falha com mensagem amigável quando o id não existe', () {
      expect(
        () => repository.desativar('inexistente'),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );
    });

    test('propaga a rejeição de domínio ao desativar um ponto já desativado (pa6)', () {
      expect(
        () => repository.desativar('pa6'),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });
  });

  group('atribuirAplicador', () {
    test('promove um ponto endereçado (pa4) a direcionado', () async {
      await repository.atribuirAplicador('pa4', '2');

      final ponto = await repository.buscarPorId('pa4');
      expect(ponto.aplicadorId, '2');
      expect(ponto.estado, EstadoPontoDeAplicacao.direcionada);
    });

    test('falha com mensagem amigável quando o id não existe', () {
      expect(
        () => repository.atribuirAplicador('inexistente', '2'),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );
    });
  });

  group('desatribuirAplicador', () {
    test('devolve um ponto direcionado (pa3) a endereçado', () async {
      await repository.desatribuirAplicador('pa3');

      final ponto = await repository.buscarPorId('pa3');
      expect(ponto.aplicadorId, isNull);
      expect(ponto.estado, EstadoPontoDeAplicacao.enderecada);
    });

    test('propaga a rejeição de domínio ao desatribuir de um ponto ativo (pa2)', () {
      expect(
        () => repository.desatribuirAplicador('pa2'),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });

    test('falha com mensagem amigável quando o id não existe', () {
      expect(
        () => repository.desatribuirAplicador('inexistente'),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );
    });
  });

  group('reativar', () {
    test('devolve um ponto desativado ao estado em que estava (pa2, ativa)', () async {
      await repository.desativar('pa2');

      await repository.reativar('pa2');

      final ponto = await repository.buscarPorId('pa2');
      expect(ponto.estado, EstadoPontoDeAplicacao.ativa);
      expect(ponto.estadoAnterior, isNull);
    });

    test('propaga a rejeição de domínio ao reativar um ponto não desativado (pa3)', () {
      expect(
        () => repository.reativar('pa3'),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });

    test('falha com mensagem amigável quando o id não existe', () {
      expect(
        () => repository.reativar('inexistente'),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );
    });
  });

  group('editarNome', () {
    test('renomeia mesmo um ponto com cadastro travado (pa1, com execução)', () async {
      await repository.editarNome('pa1', 'Nome renomeado');

      final ponto = await repository.buscarPorId('pa1');
      expect(ponto.nome, 'Nome renomeado');
    });

    test('falha com mensagem amigável quando o id não existe', () {
      expect(
        () => repository.editarNome('inexistente', 'x'),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );
    });
  });

  group('editarCadastroCompleto', () {
    Future<void> editar(String id) => repository.editarCadastroCompleto(
      id,
      nome: 'Nome editado',
      bairro: 'Bairro editado',
      endereco: 'Endereço editado',
      numeroReferencia: 'Ref editada',
      descricaoDoTrecho: 'Trecho editado.',
      larguraMetros: 9,
      profundidadeMetros: 2,
      velocidadeMetrosPorSegundo: 1.2,
      dosagemMl: 300,
      distanciaEntreSubpontosMetros: 90,
      quantidadeDeSubpontos: 12,
    );

    test('atualiza o cadastro de um ponto liberado (pa4, sem agendamento nem execução)', () async {
      await editar('pa4');

      final ponto = await repository.buscarPorId('pa4');
      expect(ponto.nome, 'Nome editado');
      expect(ponto.larguraMetros, 9);
      expect(ponto.quantidadeDeSubpontos, 12);
    });

    test('propaga a rejeição de domínio ao editar um ponto travado (pa1, com execução)', () {
      expect(() => editar('pa1'), throwsA(isA<OperacaoNaoPermitidaException>()));
    });

    test('falha com mensagem amigável quando o id não existe', () {
      expect(() => editar('inexistente'), throwsA(isA<EntidadeNaoEncontradaException>()));
    });
  });

  group('cancelarAplicacaoQuimica', () {
    test('encerra o ciclo de um ponto ativo (pa2), levando a inativa', () async {
      await repository.cancelarAplicacaoQuimica('pa2');

      final ponto = await repository.buscarPorId('pa2');
      expect(ponto.estado, EstadoPontoDeAplicacao.inativa);
    });

    test('propaga a rejeição de domínio ao cancelar um ponto que não está ativo (pa3)', () {
      expect(
        () => repository.cancelarAplicacaoQuimica('pa3'),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });

    test('falha com mensagem amigável quando o id não existe', () {
      expect(
        () => repository.cancelarAplicacaoQuimica('inexistente'),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );
    });
  });

  group('transição automática para inativa (ciclo concluído)', () {
    PontoDeAplicacao pontoAtivoComCicloConcluido() {
      final agendamento = Agendamento.gerar(
        dataInicio: DateTime(2026, 9, 1),
        intervaloDias: 15,
        quantidadeRecorrencias: 1,
      );
      return PontoDeAplicacao(
        id: 'pa_teste_ciclo_concluido',
        identificador: '#TST1',
        nome: 'Ponto de teste',
        bairro: 'Gasparinho',
        endereco: 'Rua de teste',
        numeroReferencia: 'S/N',
        descricaoDoTrecho: 'Trecho de teste.',
        larguraMetros: 2,
        profundidadeMetros: 0.5,
        velocidadeMetrosPorSegundo: 0.4,
        dosagemMl: 100,
        distanciaEntreSubpontosMetros: 50,
        quantidadeDeSubpontos: 1,
        aplicadorId: '1',
        estado: EstadoPontoDeAplicacao.ativa,
        agendamento: Agendamento(
          dataInicio: agendamento.dataInicio,
          intervaloDias: agendamento.intervaloDias,
          quantidadeRecorrencias: agendamento.quantidadeRecorrencias,
          datas: [
            agendamento.datas.single.copyWith(
              status: StatusDataAgendada.concluida,
            ),
          ],
        ),
      );
    }

    test('buscarPorId devolve inativa e persiste a transição', () async {
      mockPontosDeAplicacao.add(pontoAtivoComCicloConcluido());

      final ponto = await repository.buscarPorId('pa_teste_ciclo_concluido');

      expect(ponto.estado, EstadoPontoDeAplicacao.inativa);
      expect(
        mockPontosDeAplicacao
            .firstWhere((p) => p.id == 'pa_teste_ciclo_concluido')
            .estado,
        EstadoPontoDeAplicacao.inativa,
      );
    });

    test('listar também aplica a transição', () async {
      mockPontosDeAplicacao.add(pontoAtivoComCicloConcluido());

      final pontos = await repository.listar();

      expect(
        pontos.firstWhere((p) => p.id == 'pa_teste_ciclo_concluido').estado,
        EstadoPontoDeAplicacao.inativa,
      );
    });

    test('não transiciona um ponto ativo com ciclo ainda pendente (pa1)', () async {
      final ponto = await repository.buscarPorId('pa1');

      expect(ponto.estado, EstadoPontoDeAplicacao.ativa);
    });
  });

  group('identificador do ponto criado', () {
    test('usa as três primeiras letras do bairro e a posição dentro dele', () async {
      // O mock já traz dois pontos em Gasparinho (#GAS1 e #GAS2).
      final ponto = await criar();

      expect(ponto.identificador, '#GAS3');
    });

    test('descarta espaços e caracteres acentuados do prefixo', () async {
      final ponto = await criar(bairro: 'Poço Grande');

      // Já existe um ponto em Poço Grande no mock.
      expect(ponto.identificador, '#POO2');
    });

    test('encurta o prefixo quando sobram menos de três letras', () async {
      final ponto = await criar(bairro: 'Sé');

      expect(ponto.identificador, '#S1');
    });
  });
}
