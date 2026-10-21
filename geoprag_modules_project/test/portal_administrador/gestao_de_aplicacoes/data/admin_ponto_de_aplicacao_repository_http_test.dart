import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/bairro.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/bairro_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/data/admin_ponto_de_aplicacao_repository_http.dart';
import 'package:geoprag_modules/src/api/api_client.dart';
import 'package:geoprag_modules/src/api/api_exceptions.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:mocktail/mocktail.dart';

class _ApiFalsa extends Mock implements ApiClient {}

class _BairrosFalsos extends Mock implements BairroRepository {}

/// `Ponto` como a API o devolve (seed `PA-003`: ativo, com data em atraso).
Map<String, Object?> pontoAtivoJson({String id = 'p-3'}) => {
  'id': id,
  'identificador': 'PA-003',
  'nome': 'Travessa da Colina',
  'bairro': 'Bela Vista',
  'bairroId': 'b-2',
  'endereco': 'Travessa da Colina',
  'numeroReferencia': '45',
  'descricaoDoTrecho': 'Trecho da canaleta',
  'larguraMetros': 1.5,
  'profundidadeMetros': 0.3,
  'velocidadeMetrosPorSegundo': 0.8,
  'dosagemMl': 25.0,
  'distanciaEntreSubpontosMetros': 5.0,
  'quantidadeDeSubpontos': 6,
  'toleranciaAtrasoDias': 4,
  'aplicadorId': 'ap-3',
  'estado': 'ATIVA',
  'estadoAnterior': 'DIRECIONADA',
  'agendamento': {
    'dataInicio': '2026-10-05',
    'intervaloDias': 7,
    'quantidadeRecorrencias': 3,
    'datas': [
      {'id': 'd-1', 'data': '2026-10-05', 'status': 'CONCLUIDA'},
      {'id': 'd-2', 'data': '2026-10-12', 'status': 'PENDENTE'},
    ],
  },
  'subpontos': [
    {
      'id': 's-1',
      'latitude': -26.9,
      'longitude': -48.9,
      'realizadoEm': '2026-10-05T09:00:00Z',
      'recebidoEm': '2026-10-05T12:00:00Z',
      'conflito': true,
      'motivoConflito': 'PONTO_REATRIBUIDO',
    },
  ],
};

/// `PA-001` do seed: endereçado, sem aplicador e sem as medidas do trecho.
Map<String, Object?> pontoEnderecadoJson() => {
  'id': 'p-1',
  'identificador': 'PA-001',
  'nome': 'Rua das Flores, trecho 1',
  'bairro': 'Centro',
  'bairroId': 'b-1',
  'endereco': 'Rua das Flores',
  'numeroReferencia': null,
  'descricaoDoTrecho': null,
  'larguraMetros': null,
  'profundidadeMetros': null,
  'velocidadeMetrosPorSegundo': null,
  'dosagemMl': 20.0,
  'distanciaEntreSubpontosMetros': 10.0,
  'quantidadeDeSubpontos': 10,
  'toleranciaAtrasoDias': 4,
  'aplicadorId': null,
  'estado': 'ENDERECADA',
  'estadoAnterior': null,
  'agendamento': null,
  'subpontos': <Object?>[],
};

void main() {
  late _ApiFalsa api;
  late _BairrosFalsos bairros;
  late AdminPontoDeAplicacaoRepositoryHttp repositorio;

  setUp(() {
    api = _ApiFalsa();
    bairros = _BairrosFalsos();
    repositorio = AdminPontoDeAplicacaoRepositoryHttp(api, bairros);
  });

  group('leitura', () {
    test('listar lê GET /pontos e converte para o domínio', () async {
      when(
        () => api.get('/pontos', query: any(named: 'query')),
      ).thenAnswer((_) async => [pontoAtivoJson(), pontoEnderecadoJson()]);

      final pontos = await repositorio.listar();

      expect(pontos, hasLength(2));
      final ativo = pontos.first;
      expect(ativo.id, 'p-3');
      expect(ativo.identificador, 'PA-003');
      expect(ativo.bairro, 'Bela Vista');
      expect(ativo.estado, EstadoPontoDeAplicacao.ativa);
      expect(ativo.estadoAnterior, EstadoPontoDeAplicacao.direcionada);
      expect(ativo.aplicadorId, 'ap-3');
      expect(ativo.vazao, closeTo(0.36, 0.0001));
      expect(ativo.agendamento!.datas.map((d) => d.id), ['d-1', 'd-2']);
      expect(ativo.agendamento!.datas.last.status, StatusDataAgendada.pendente);
      expect(ativo.subpontos.single.id, 's-1');
      verify(() => api.get('/pontos', query: null)).called(1);
    });

    test(
      'ponto sem as medidas do trecho vem com texto vazio e medida zero',
      () async {
        when(
          () => api.get('/pontos', query: any(named: 'query')),
        ).thenAnswer((_) async => [pontoEnderecadoJson()]);

        final ponto = (await repositorio.listar()).single;

        expect(ponto.estado, EstadoPontoDeAplicacao.enderecada);
        expect(ponto.aplicadorId, isNull);
        expect(ponto.numeroReferencia, isEmpty);
        expect(ponto.descricaoDoTrecho, isEmpty);
        expect(ponto.larguraMetros, 0);
        expect(ponto.vazao, 0);
      },
    );

    test('lista vazia é uma lista vazia', () async {
      when(
        () => api.get('/pontos', query: any(named: 'query')),
      ).thenAnswer((_) async => <Object?>[]);

      expect(await repositorio.listar(), isEmpty);
    });

    test('listarPorBairro filtra pelo nome do bairro na API', () async {
      when(
        () => api.get('/pontos', query: any(named: 'query')),
      ).thenAnswer((_) async => [pontoAtivoJson()]);

      final pontos = await repositorio.listarPorBairro('Bela Vista');

      expect(pontos.single.bairro, 'Bela Vista');
      verify(
        () => api.get('/pontos', query: {'bairro': 'Bela Vista'}),
      ).called(1);
    });

    test('buscarPorId lê GET /pontos/{id}, com o id codificado', () async {
      when(() => api.get(any())).thenAnswer((_) async => pontoAtivoJson());

      final ponto = await repositorio.buscarPorId('a b/c');

      expect(ponto.id, 'p-3');
      verify(() => api.get('/pontos/a%20b%2Fc')).called(1);
    });

    test(
      'ponto inexistente (404) chega como EntidadeNaoEncontradaException',
      () async {
        when(() => api.get(any())).thenThrow(
          const EntidadeNaoEncontradaException('Ponto não encontrado.'),
        );

        await expectLater(
          repositorio.buscarPorId('x'),
          throwsA(
            isA<EntidadeNaoEncontradaException>().having(
              (e) => e.mensagemAmigavel,
              'mensagem',
              'Ponto não encontrado.',
            ),
          ),
        );
      },
    );

    test('servidor fora do ar chega como a exceção amigável da API', () async {
      when(
        () => api.get('/pontos', query: any(named: 'query')),
      ).thenThrow(const FalhaDeConexaoException('Sem conexão com o servidor.'));

      await expectLater(
        repositorio.listar(),
        throwsA(isA<FalhaDeConexaoException>()),
      );
    });

    test('resposta que não é lista é recusada', () async {
      when(
        () => api.get('/pontos', query: any(named: 'query')),
      ).thenAnswer((_) async => {'erro': 'gateway'});

      await expectLater(repositorio.listar(), throwsFormatException);
    });

    test('estado desconhecido do servidor é recusado, não ignorado', () async {
      when(
        () => api.get(any()),
      ).thenAnswer((_) async => {...pontoAtivoJson(), 'estado': 'ARQUIVADO'});

      await expectLater(repositorio.buscarPorId('p-3'), throwsFormatException);
    });
  });

  group('transições', () {
    final agendamento = Agendamento.gerar(
      dataInicio: DateTime(2026, 10, 25),
      intervaloDias: 7,
      quantidadeRecorrencias: 3,
    );

    test('ativar manda só data de início, intervalo e recorrências', () async {
      when(
        () => api.post(any(), corpo: any(named: 'corpo')),
      ).thenAnswer((_) async => pontoAtivoJson());

      await repositorio.ativar('p-1', agendamento);

      final corpo =
          verify(
                () => api.post(
                  '/pontos/p-1/ativacao',
                  corpo: captureAny(named: 'corpo'),
                ),
              ).captured.single
              as Map<String, Object?>;
      // As datas e os ids que o cliente gerou ficam de fora: o servidor gera.
      expect(corpo, {
        'dataInicio': '2026-10-25',
        'intervaloDias': 7,
        'quantidadeRecorrencias': 3,
      });
    });

    test('atribuirAplicador manda o aplicadorId', () async {
      when(
        () => api.post(any(), corpo: any(named: 'corpo')),
      ).thenAnswer((_) async => pontoAtivoJson());

      await repositorio.atribuirAplicador('p-1', 'ap-3');

      verify(
        () => api.post('/pontos/p-1/aplicador', corpo: {'aplicadorId': 'ap-3'}),
      ).called(1);
    });

    test('desatribuirAplicador chama DELETE /pontos/{id}/aplicador', () async {
      when(() => api.delete(any())).thenAnswer((_) async => pontoAtivoJson());

      await repositorio.desatribuirAplicador('p-1');

      verify(() => api.delete('/pontos/p-1/aplicador')).called(1);
    });

    test(
      'conflito de estado (409) chega como OperacaoNaoPermitidaException',
      () async {
        when(() => api.post(any(), corpo: any(named: 'corpo'))).thenThrow(
          const OperacaoNaoPermitidaException(
            'O aplicador está desativado e não pode ser atribuído a um ponto.',
          ),
        );

        await expectLater(
          repositorio.atribuirAplicador('p-1', 'ap-9'),
          throwsA(
            isA<OperacaoNaoPermitidaException>().having(
              (e) => e.mensagemAmigavel,
              'mensagem',
              contains('desativado'),
            ),
          ),
        );
      },
    );

    test(
      'validação do servidor (422) chega como RequisicaoInvalidaException',
      () async {
        when(() => api.post(any(), corpo: any(named: 'corpo'))).thenThrow(
          const RequisicaoInvalidaException(
            'O intervalo deve ser de pelo menos 1 dia.',
            status: 422,
          ),
        );

        await expectLater(
          repositorio.ativar('p-1', agendamento),
          throwsA(
            isA<RequisicaoInvalidaException>().having(
              (e) => e.mensagemAmigavel,
              'mensagem',
              'O intervalo deve ser de pelo menos 1 dia.',
            ),
          ),
        );
      },
    );

    test(
      'ponto inexistente (404) ao atribuir chega como não encontrado',
      () async {
        when(() => api.post(any(), corpo: any(named: 'corpo'))).thenThrow(
          const EntidadeNaoEncontradaException('Ponto não encontrado.'),
        );

        await expectLater(
          repositorio.atribuirAplicador('x', 'ap-3'),
          throwsA(isA<EntidadeNaoEncontradaException>()),
        );
      },
    );
  });

  group('ações do ciclo de vida (GEOPRAG-198)', () {
    final transicoes = <String, (String, Future<void> Function())>{};

    setUp(() {
      transicoes
        ..clear()
        ..addAll({
          'desativar': (
            '/pontos/p-1/desativacao',
            () => repositorio.desativar('p-1'),
          ),
          'reativar': (
            '/pontos/p-1/reativacao',
            () => repositorio.reativar('p-1'),
          ),
          'cancelarAplicacaoQuimica': (
            '/pontos/p-1/cancelamento',
            () => repositorio.cancelarAplicacaoQuimica('p-1'),
          ),
        });
      when(() => api.post(any())).thenAnswer((_) async => pontoAtivoJson());
    });

    for (final nome in ['desativar', 'reativar', 'cancelarAplicacaoQuimica']) {
      test('$nome faz POST no caminho da transição, sem corpo', () async {
        final (caminho, acao) = transicoes[nome]!;

        await acao();

        verify(() => api.post(caminho)).called(1);
      });

      test('$nome devolve o 409 do servidor com a mensagem dele', () async {
        final (_, acao) = transicoes[nome]!;
        when(() => api.post(any())).thenThrow(
          const OperacaoNaoPermitidaException('O ponto já está desativado.'),
        );

        await expectLater(
          acao(),
          throwsA(
            isA<OperacaoNaoPermitidaException>().having(
              (e) => e.mensagemAmigavel,
              'mensagem',
              'O ponto já está desativado.',
            ),
          ),
        );
      });
    }
  });

  group('criar e editar (GEOPRAG-198)', () {
    setUp(() {
      when(() => bairros.listar()).thenAnswer(
        (_) async => const [
          Bairro(id: 'b-1', nome: 'Centro'),
          Bairro(id: 'b-2', nome: 'Bela Vista'),
        ],
      );
    });

    Future<PontoDeAplicacao> criar({
      String bairro = 'bela vista',
      String? aplicadorId,
      double largura = 1.5,
      String referencia = ' 45 ',
    }) => repositorio.criar(
      nome: ' Travessa da Colina ',
      bairro: bairro,
      endereco: 'Travessa da Colina',
      numeroReferencia: referencia,
      descricaoDoTrecho: 'Trecho da canaleta',
      larguraMetros: largura,
      profundidadeMetros: 0.3,
      velocidadeMetrosPorSegundo: 0.8,
      dosagemMl: 25,
      distanciaEntreSubpontosMetros: 5,
      quantidadeDeSubpontos: 6,
      aplicadorId: aplicadorId,
    );

    Map<String, dynamic> corpoDoPost() =>
        verify(
              () => api.post('/pontos', corpo: captureAny(named: 'corpo')),
            ).captured.single
            as Map<String, dynamic>;

    Map<String, dynamic> corpoDoPut(String id) =>
        verify(
              () => api.put('/pontos/$id', corpo: captureAny(named: 'corpo')),
            ).captured.single
            as Map<String, dynamic>;

    test(
      'criar faz POST /pontos com o bairroId e devolve o ponto criado',
      () async {
        when(
          () => api.post('/pontos', corpo: any(named: 'corpo')),
        ).thenAnswer((_) async => pontoAtivoJson());

        final ponto = await criar(aplicadorId: 'ap-3');

        expect(ponto.id, 'p-3');
        expect(corpoDoPost(), {
          'nome': 'Travessa da Colina',
          'bairroId': 'b-2',
          'endereco': 'Travessa da Colina',
          'numeroReferencia': '45',
          'descricaoDoTrecho': 'Trecho da canaleta',
          'larguraMetros': 1.5,
          'profundidadeMetros': 0.3,
          'velocidadeMetrosPorSegundo': 0.8,
          'dosagemMl': 25.0,
          'distanciaEntreSubpontosMetros': 5.0,
          'quantidadeDeSubpontos': 6,
          'aplicadorId': 'ap-3',
        });
      },
    );

    test('criar sem aplicador e sem medida omite os campos vazios', () async {
      when(
        () => api.post('/pontos', corpo: any(named: 'corpo')),
      ).thenAnswer((_) async => pontoEnderecadoJson());

      await criar(largura: 0, referencia: '  ');

      final corpo = corpoDoPost();
      expect(corpo.containsKey('aplicadorId'), isFalse);
      expect(corpo.containsKey('larguraMetros'), isFalse);
      expect(corpo.containsKey('numeroReferencia'), isFalse);
      expect(corpo.containsKey('toleranciaAtrasoDias'), isFalse);
    });

    test('as medidas vão com no máximo 2 casas decimais', () async {
      when(
        () => api.post('/pontos', corpo: any(named: 'corpo')),
      ).thenAnswer((_) async => pontoAtivoJson());

      await criar(largura: 0.1 + 0.2);

      expect(corpoDoPost()['larguraMetros'], 0.3);
    });

    test('bairro que não existe: erro claro e nada vai à API', () async {
      await expectLater(
        criar(bairro: 'Lugar nenhum'),
        throwsA(
          isA<RequisicaoInvalidaException>().having(
            (e) => e.mensagemAmigavel,
            'mensagem',
            contains('Lugar nenhum'),
          ),
        ),
      );
      verifyNever(() => api.post(any(), corpo: any(named: 'corpo')));
    });

    test('422 do servidor chega com a mensagem dele', () async {
      when(() => api.post('/pontos', corpo: any(named: 'corpo'))).thenThrow(
        const RequisicaoInvalidaException('A largura deve ser maior que zero.'),
      );

      await expectLater(
        criar(),
        throwsA(
          isA<RequisicaoInvalidaException>().having(
            (e) => e.mensagemAmigavel,
            'mensagem',
            'A largura deve ser maior que zero.',
          ),
        ),
      );
    });

    test(
      'editarCadastroCompleto faz PUT e reenvia a tolerância atual',
      () async {
        when(() => api.get('/pontos/p-3')).thenAnswer(
          (_) async => {...pontoAtivoJson(), 'toleranciaAtrasoDias': 9},
        );
        when(
          () => api.put('/pontos/p-3', corpo: any(named: 'corpo')),
        ).thenAnswer((_) async => pontoAtivoJson());

        await repositorio.editarCadastroCompleto(
          'p-3',
          nome: 'Novo nome',
          bairro: 'Centro',
          endereco: 'Rua nova',
          numeroReferencia: '10',
          descricaoDoTrecho: 'Outro trecho',
          larguraMetros: 2,
          profundidadeMetros: 0.5,
          velocidadeMetrosPorSegundo: 0.4,
          dosagemMl: 30,
          distanciaEntreSubpontosMetros: 8,
          quantidadeDeSubpontos: 5,
        );

        final corpo = corpoDoPut('p-3');
        expect(corpo['nome'], 'Novo nome');
        expect(corpo['bairroId'], 'b-1');
        expect(corpo['endereco'], 'Rua nova');
        expect(corpo['quantidadeDeSubpontos'], 5);
        expect(corpo['toleranciaAtrasoDias'], 9);
        expect(corpo.containsKey('aplicadorId'), isFalse);
      },
    );

    test(
      'editarNome reenvia o cadastro como está, só com o nome novo',
      () async {
        when(
          () => api.get('/pontos/p-3'),
        ).thenAnswer((_) async => pontoAtivoJson());
        when(
          () => api.put('/pontos/p-3', corpo: any(named: 'corpo')),
        ).thenAnswer((_) async => pontoAtivoJson());

        await repositorio.editarNome('p-3', 'Nome melhor');

        expect(corpoDoPut('p-3'), {
          'nome': 'Nome melhor',
          'bairroId': 'b-2',
          'endereco': 'Travessa da Colina',
          'numeroReferencia': '45',
          'descricaoDoTrecho': 'Trecho da canaleta',
          'larguraMetros': 1.5,
          'profundidadeMetros': 0.3,
          'velocidadeMetrosPorSegundo': 0.8,
          'dosagemMl': 25.0,
          'distanciaEntreSubpontosMetros': 5.0,
          'quantidadeDeSubpontos': 6,
          'toleranciaAtrasoDias': 4,
        });
        verifyNever(() => bairros.listar());
      },
    );

    test('editarNome de ponto sem medidas não envia campo nulo', () async {
      when(
        () => api.get('/pontos/p-1'),
      ).thenAnswer((_) async => pontoEnderecadoJson());
      when(
        () => api.put('/pontos/p-1', corpo: any(named: 'corpo')),
      ).thenAnswer((_) async => pontoEnderecadoJson());

      await repositorio.editarNome('p-1', 'Rua das Flores, trecho 2');

      final corpo = corpoDoPut('p-1');
      expect(corpo.values.any((v) => v == null), isFalse);
      expect(corpo.containsKey('larguraMetros'), isFalse);
    });

    test(
      '409 ao editar o cadastro travado chega com a mensagem do servidor',
      () async {
        when(
          () => api.get('/pontos/p-3'),
        ).thenAnswer((_) async => pontoAtivoJson());
        when(
          () => api.put('/pontos/p-3', corpo: any(named: 'corpo')),
        ).thenThrow(
          const OperacaoNaoPermitidaException(
            'O cadastro do ponto só pode ser alterado enquanto ele não tem '
            'agendamento vigente nem aplicação registrada.',
          ),
        );

        await expectLater(
          repositorio.editarCadastroCompleto(
            'p-3',
            nome: 'n',
            bairro: 'Centro',
            endereco: 'e',
            numeroReferencia: '1',
            descricaoDoTrecho: 'd',
            larguraMetros: 1,
            profundidadeMetros: 1,
            velocidadeMetrosPorSegundo: 1,
            dosagemMl: 1,
            distanciaEntreSubpontosMetros: 1,
            quantidadeDeSubpontos: 1,
          ),
          throwsA(
            isA<OperacaoNaoPermitidaException>().having(
              (e) => e.mensagemAmigavel,
              'mensagem',
              contains('agendamento vigente'),
            ),
          ),
        );
      },
    );

    test(
      'ponto inexistente ao editar o nome chega como não encontrado',
      () async {
        when(() => api.get('/pontos/x')).thenThrow(
          const EntidadeNaoEncontradaException('Ponto não encontrado.'),
        );

        await expectLater(
          repositorio.editarNome('x', 'Nome'),
          throwsA(isA<EntidadeNaoEncontradaException>()),
        );
        verifyNever(() => api.put(any(), corpo: any(named: 'corpo')));
      },
    );
  });
}
