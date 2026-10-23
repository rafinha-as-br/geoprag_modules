import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/data/admin_ponto_de_aplicacao_repository_impl.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/data/mock_pontos_de_aplicacao.dart';
import 'package:geoprag_modules/src/atraso/alerta_de_atraso_repository_impl.dart';
import 'package:geoprag_modules/src/auditoria/evento_auditoria.dart';
import 'package:geoprag_modules/src/auditoria/evento_auditoria_repository_impl.dart';
import 'package:geoprag_modules/src/entities/atraso_de_aplicacao.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';

void main() {
  late AdminPontoDeAplicacaoRepositoryImpl repository;
  late List<PontoDeAplicacao> snapshotOriginal;

  const autor = AutorUsuario(
    email: 'admin@gaspar.sc.gov.br',
    perfil: 'administrador',
  );

  var hoje = DateTime(2026, 10, 10);

  setUp(() {
    hoje = DateTime(2026, 10, 10);
    repository = AdminPontoDeAplicacaoRepositoryImpl(
      eventoAuditoriaRepository: EventoAuditoriaRepositoryImpl(),
      alertaDeAtrasoRepository: AlertaDeAtrasoRepositoryImpl(),
      autor: autor,
      agora: () => hoje,
    );
    snapshotOriginal = List.of(mockPontosDeAplicacao);
  });

  tearDown(() {
    mockEventosAuditoria.clear();
    mockAlertasDeAtrasoRemovidos.clear();
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
    int toleranciaDias = toleranciaPadraoDeAtrasoEmDias,
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
    toleranciaDias: toleranciaDias,
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

  test('ponto criado sem tolerância informada nasce com o padrão de 4 dias',
      () async {
    final ponto = await criar();

    expect(ponto.toleranciaDias, 4);
    expect((await repository.buscarPorId(ponto.id)).toleranciaDias, 4);
  });

  test('ponto criado aceita uma tolerância própria', () async {
    final ponto = await criar(toleranciaDias: 10);

    expect(ponto.toleranciaDias, 10);
    expect((await repository.buscarPorId(ponto.id)).toleranciaDias, 10);
  });

  test('criar rejeita tolerância inválida e não cadastra o ponto', () async {
    final totalAntes = mockPontosDeAplicacao.length;

    await expectLater(
      () => criar(toleranciaDias: 0),
      throwsA(isA<OperacaoNaoPermitidaException>()),
    );

    expect(mockPontosDeAplicacao.length, totalAntes);
  });

  test('o mock tem pontos com a tolerância padrão e um com tolerância própria',
      () async {
    final pontos = await repository.listar();

    expect(pontos.map((p) => p.toleranciaDias), contains(4));
    expect((await repository.buscarPorId('pa2')).toleranciaDias, 7);
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

  group('editarTolerancia', () {
    test('altera a tolerância mesmo de um ponto com cadastro travado (pa1, com execução)',
        () async {
      expect((await repository.buscarPorId('pa1')).podeEditarCadastroCompleto,
          isFalse);

      await repository.editarTolerancia('pa1', 9);

      expect((await repository.buscarPorId('pa1')).toleranciaDias, 9);
    });

    test('altera a tolerância de um ponto com cadastro liberado (pa4)', () async {
      await repository.editarTolerancia('pa4', 2);

      expect((await repository.buscarPorId('pa4')).toleranciaDias, 2);
    });

    test('não mexe no resto do ponto', () async {
      final antes = await repository.buscarPorId('pa1');

      await repository.editarTolerancia('pa1', 9);

      final depois = await repository.buscarPorId('pa1');
      expect(depois.nome, antes.nome);
      expect(depois.agendamento, antes.agendamento);
      expect(depois.subpontos, antes.subpontos);
      expect(depois.dosagemMl, antes.dosagemMl);
    });

    test('rejeita zero e valor negativo sem alterar o ponto', () async {
      final antes = (await repository.buscarPorId('pa1')).toleranciaDias;

      await expectLater(
        () => repository.editarTolerancia('pa1', 0),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
      await expectLater(
        () => repository.editarTolerancia('pa1', -2),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );

      expect((await repository.buscarPorId('pa1')).toleranciaDias, antes);
    });

    test('falha com mensagem amigável quando o id não existe', () {
      expect(
        () => repository.editarTolerancia('inexistente', 5),
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
      toleranciaDias: 6,
    );

    test('atualiza o cadastro de um ponto liberado (pa4, sem agendamento nem execução)', () async {
      await editar('pa4');

      final ponto = await repository.buscarPorId('pa4');
      expect(ponto.nome, 'Nome editado');
      expect(ponto.larguraMetros, 9);
      expect(ponto.quantidadeDeSubpontos, 12);
      expect(ponto.toleranciaDias, 6);
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

  group('emissão de eventos de auditoria (GEOPRAG-113)', () {
    test('criar emite ponto_criado com o autor informado', () async {
      final ponto = await criar(aplicadorId: '1');

      final evento = mockEventosAuditoria.single;
      expect(evento.tipo, 'ponto_criado');
      expect(evento.pontoAfetadoId, ponto.id);
      expect(evento.autor, autor);
      expect(evento.payload['aplicadorId'], '1');
    });

    test('ativar emite ciclo_ativado com os dados do agendamento', () async {
      final agendamento = Agendamento.gerar(
        dataInicio: DateTime(2026, 9, 10),
        intervaloDias: 15,
        quantidadeRecorrencias: 3,
      );

      await repository.ativar('pa3', agendamento);

      final evento = mockEventosAuditoria.single;
      expect(evento.tipo, 'ciclo_ativado');
      expect(evento.pontoAfetadoId, 'pa3');
      expect(evento.payload['quantidadeRecorrencias'], 3);
    });

    test('editarNome emite nome_editado com o nome anterior e o novo', () async {
      await repository.editarNome('pa1', 'Nome renomeado');

      final evento = mockEventosAuditoria.single;
      expect(evento.tipo, 'nome_editado');
      expect(evento.payload['nomeNovo'], 'Nome renomeado');
    });

    test(
      'editarCadastroCompleto emite cadastro_editado só com os campos alterados',
      () async {
        final antes = await repository.buscarPorId('pa4');

        await repository.editarCadastroCompleto(
          'pa4',
          nome: 'Nome editado',
          bairro: antes.bairro,
          endereco: antes.endereco,
          numeroReferencia: antes.numeroReferencia,
          descricaoDoTrecho: antes.descricaoDoTrecho,
          larguraMetros: antes.larguraMetros,
          profundidadeMetros: antes.profundidadeMetros,
          velocidadeMetrosPorSegundo: antes.velocidadeMetrosPorSegundo,
          dosagemMl: antes.dosagemMl,
          distanciaEntreSubpontosMetros: antes.distanciaEntreSubpontosMetros,
          quantidadeDeSubpontos: antes.quantidadeDeSubpontos,
          toleranciaDias: antes.toleranciaDias,
        );

        final evento = mockEventosAuditoria.single;
        expect(evento.tipo, 'cadastro_editado');
        expect(evento.payload.keys, ['nome']);
        expect(evento.payload['nome'], {'de': antes.nome, 'para': 'Nome editado'});
      },
    );

    test('editarCadastroCompleto inclui a tolerância no delta quando ela muda',
        () async {
      final antes = await repository.buscarPorId('pa4');

      await repository.editarCadastroCompleto(
        'pa4',
        nome: antes.nome,
        bairro: antes.bairro,
        endereco: antes.endereco,
        numeroReferencia: antes.numeroReferencia,
        descricaoDoTrecho: antes.descricaoDoTrecho,
        larguraMetros: antes.larguraMetros,
        profundidadeMetros: antes.profundidadeMetros,
        velocidadeMetrosPorSegundo: antes.velocidadeMetrosPorSegundo,
        dosagemMl: antes.dosagemMl,
        distanciaEntreSubpontosMetros: antes.distanciaEntreSubpontosMetros,
        quantidadeDeSubpontos: antes.quantidadeDeSubpontos,
        toleranciaDias: 8,
      );

      final evento = mockEventosAuditoria.single;
      expect(evento.tipo, 'cadastro_editado');
      expect(evento.payload.keys, ['toleranciaDias']);
      expect(evento.payload['toleranciaDias'], {'de': 4, 'para': 8});
    });

    test('editarTolerancia emite tolerancia_editada com o valor anterior e o novo',
        () async {
      await repository.editarTolerancia('pa1', 9);

      final evento = mockEventosAuditoria.single;
      expect(evento.tipo, 'tolerancia_editada');
      expect(evento.pontoAfetadoId, 'pa1');
      expect(evento.autor, autor);
      expect(evento.payload, {
        'toleranciaAnteriorDias': 4,
        'toleranciaNovaDias': 9,
      });
    });

    test('editarTolerancia com o mesmo valor não emite evento', () async {
      await repository.editarTolerancia('pa1', 4);

      expect(mockEventosAuditoria, isEmpty);
    });

    test('editarTolerancia inválida não emite evento', () async {
      await expectLater(
        () => repository.editarTolerancia('pa1', 0),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );

      expect(mockEventosAuditoria, isEmpty);
    });

    test('criar registra a tolerância no evento ponto_criado', () async {
      await criar(toleranciaDias: 6);

      final evento = mockEventosAuditoria.single;
      expect(evento.tipo, 'ponto_criado');
      expect(evento.payload['toleranciaDias'], 6);
    });

    test('uma ação que falha (id inexistente) não emite evento', () async {
      await expectLater(
        () => repository.desativar('inexistente'),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );

      expect(mockEventosAuditoria, isEmpty);
    });
  });

  group('alerta de atraso (GEOPRAG-160)', () {
    // Ciclo de 3 datas semanais a partir de 01/10: com "hoje" em 10/10 e a
    // tolerância padrão de 4 dias, a primeira data (01/10) está em atraso.
    Future<PontoDeAplicacao> pontoAtivoComCiclo({int? toleranciaDias}) async {
      final ponto = await criar(
        aplicadorId: '1',
        toleranciaDias: toleranciaDias ?? toleranciaPadraoDeAtrasoEmDias,
      );
      await repository.ativar(
        ponto.id,
        Agendamento.gerar(
          dataInicio: DateTime(2026, 10, 1),
          intervaloDias: 7,
          quantidadeRecorrencias: 3,
        ),
      );
      mockEventosAuditoria.clear();
      return ponto;
    }

    test('ponto cuja data pendente passou da tolerância está em atraso',
        () async {
      final ponto = await pontoAtivoComCiclo();

      expect(await repository.idsDePontosEmAtraso(), contains(ponto.id));
    });

    test('no último dia da tolerância ainda está em dia', () async {
      final ponto = await pontoAtivoComCiclo();
      hoje = DateTime(2026, 10, 5);

      expect(await repository.idsDePontosEmAtraso(), isNot(contains(ponto.id)));
    });

    test('usa a tolerância do próprio ponto', () async {
      final ponto = await pontoAtivoComCiclo(toleranciaDias: 12);

      expect(await repository.idsDePontosEmAtraso(), isNot(contains(ponto.id)));
    });

    test('ponto sem agendamento nunca está em atraso', () async {
      final ponto = await criar(aplicadorId: '1');

      expect(await repository.idsDePontosEmAtraso(), isNot(contains(ponto.id)));
    });

    test('remover o alerta tira o ponto do atraso e emite auditoria', () async {
      final ponto = await pontoAtivoComCiclo();

      await repository.removerAlertaDeAtraso(ponto.id);

      expect(await repository.idsDePontosEmAtraso(), isNot(contains(ponto.id)));
      final evento = mockEventosAuditoria.single;
      expect(evento.tipo, 'alerta_atraso_removido');
      expect(evento.pontoAfetadoId, ponto.id);
      expect(evento.autor, autor);
      expect(evento.payload['dataAgendadaId'], '2026-10-01-0');
    });

    test('a remoção vale só para o atraso atual: a próxima recorrência '
        'atrasada volta a alertar', () async {
      final ponto = await pontoAtivoComCiclo();
      await repository.removerAlertaDeAtraso(ponto.id);

      // A aplicação atrasada é concluída (cumpre 01/10) e a seguinte (08/10)
      // também passa da tolerância em 20/10.
      final index = mockPontosDeAplicacao.indexWhere((p) => p.id == ponto.id);
      for (var i = 0; i < ponto.quantidadeDeSubpontos; i++) {
        mockPontosDeAplicacao[index] = mockPontosDeAplicacao[index]
            .registrarSubponto(
              Subponto(
                latitude: -26.9,
                longitude: -48.9,
                realizadoEm: DateTime(2026, 10, 9),
                registradoEm: DateTime(2026, 10, 9),
              ),
            );
      }
      hoje = DateTime(2026, 10, 20);

      expect(await repository.idsDePontosEmAtraso(), contains(ponto.id));
    });

    test('remover o alerta de um ponto em dia é rejeitado, sem evento',
        () async {
      final ponto = await pontoAtivoComCiclo(toleranciaDias: 12);

      await expectLater(
        () => repository.removerAlertaDeAtraso(ponto.id),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
      expect(mockEventosAuditoria, isEmpty);
    });

    test('remover duas vezes o mesmo alerta é rejeitado na segunda', () async {
      final ponto = await pontoAtivoComCiclo();
      await repository.removerAlertaDeAtraso(ponto.id);

      await expectLater(
        () => repository.removerAlertaDeAtraso(ponto.id),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
      expect(mockEventosAuditoria, hasLength(1));
    });

    test('remover o alerta de id inexistente falha com mensagem amigável', () {
      expect(
        () => repository.removerAlertaDeAtraso('inexistente'),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );
    });
  });
}
