import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/data/admin_ponto_de_aplicacao_repository_http.dart';
import 'package:geoprag_modules/src/api/api_client.dart';
import 'package:geoprag_modules/src/api/api_exceptions.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/src/errors/app_error_messages.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:mocktail/mocktail.dart';

class _ApiFalsa extends Mock implements ApiClient {}

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
  late AdminPontoDeAplicacaoRepositoryHttp repositorio;

  setUp(() {
    api = _ApiFalsa();
    repositorio = AdminPontoDeAplicacaoRepositoryHttp(api);
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

  group('ações que ainda não foram ligadas à API (GEOPRAG-198)', () {
    final acoes =
        <String, Future<Object?> Function(AdminPontoDeAplicacaoRepositoryHttp)>{
          'desativar': (r) => r.desativar('p-1'),
          'reativar': (r) => r.reativar('p-1'),
          'editarNome': (r) => r.editarNome('p-1', 'Novo nome'),
          'cancelarAplicacaoQuimica': (r) => r.cancelarAplicacaoQuimica('p-1'),
          'editarCadastroCompleto': (r) => r.editarCadastroCompleto(
            'p-1',
            nome: 'n',
            bairro: 'b',
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
          'criar': (r) => r.criar(
            nome: 'n',
            bairro: 'b',
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
        };

    for (final MapEntry(key: nome, value: acao) in acoes.entries) {
      test(
        '$nome responde que não está disponível e não chama a API',
        () async {
          await expectLater(
            acao(repositorio),
            throwsA(
              isA<OperacaoNaoPermitidaException>().having(
                (e) => e.mensagemAmigavel,
                'mensagem',
                AppErrorMessages.acaoIndisponivelNestaVersao,
              ),
            ),
          );
          verifyZeroInteractions(api);
        },
      );
    }
  });
}
