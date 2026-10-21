import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/geoprag_modules.dart';

Map<String, dynamic> _pontoJson({Map<String, dynamic> extras = const {}}) => {
  'id': 'p-0001',
  'identificador': 'PA-003',
  'nome': 'Travessa da Colina',
  'bairro': 'Bela Vista',
  'bairroId': 'b-0002',
  'endereco': 'Travessa da Colina',
  'numeroReferencia': '45',
  'descricaoDoTrecho': null,
  'larguraMetros': null,
  'profundidadeMetros': null,
  'velocidadeMetrosPorSegundo': null,
  'dosagemMl': 25.0,
  'distanciaEntreSubpontosMetros': 5.0,
  'quantidadeDeSubpontos': 6,
  'toleranciaAtrasoDias': 4,
  'aplicadorId': 'u-0003',
  'estado': 'ATIVA',
  'estadoAnterior': 'DIRECIONADA',
  'agendamento': {
    'dataInicio': '2026-10-05',
    'intervaloDias': 7,
    'quantidadeRecorrencias': 3,
    'datas': [
      {'id': 'd-0001', 'data': '2026-10-05', 'status': 'CONCLUIDA'},
      {'id': 'd-0002', 'data': '2026-10-12', 'status': 'PENDENTE'},
      {'id': 'd-0003', 'data': '2026-10-19', 'status': 'CANCELADA'},
    ],
  },
  'subpontos': [
    {
      'id': 's-0001',
      'latitude': -26.9317,
      'longitude': -48.9589,
      'realizadoEm': '2026-10-12T14:30:00-03:00',
      'recebidoEm': '2026-10-12T18:05:12+00:00',
    },
  ],
  ...extras,
};

void main() {
  group('PullResponseDto', () {
    test('lê o snapshot completo (pontos, produtos, cursor e removidos)', () {
      final dto = PullResponseDto.fromJson({
        'pontos': [_pontoJson()],
        'produtos': [
          {'id': 'pr-0001', 'nome': 'Larvicida (exemplo)'},
        ],
        'cursor': '2026-10-21T18:05:12-03:00',
        'removidos': <String>[],
      });

      expect(dto.pontos.single.id, 'p-0001');
      expect(dto.produtos.single.nome, 'Larvicida (exemplo)');
      expect(dto.cursor!.toUtc(), DateTime.utc(2026, 10, 21, 21, 5, 12));
      expect(dto.removidos, isEmpty);
    });

    test('formato v0 (sem cursor nem removidos) continua aceito', () {
      final dto = PullResponseDto.fromJson({
        'pontos': [_pontoJson()],
        'produtos': <Map<String, dynamic>>[],
      });

      expect(dto.cursor, isNull);
      expect(dto.removidos, isEmpty);
    });

    test('incremental: lê os removidos', () {
      final dto = PullResponseDto.fromJson({
        'pontos': <Map<String, dynamic>>[],
        'produtos': <Map<String, dynamic>>[],
        'cursor': '2026-10-21T18:20:40-03:00',
        'removidos': ['p-0009'],
      });

      expect(dto.removidos, ['p-0009']);
    });

    test('lista obrigatória ausente ou cursor sem offset vira FormatException', () {
      expect(
        () => PullResponseDto.fromJson({'produtos': <Map<String, dynamic>>[]}),
        throwsFormatException,
      );
      expect(
        () => PullResponseDto.fromJson({
          'pontos': <Map<String, dynamic>>[],
          'produtos': <Map<String, dynamic>>[],
          'cursor': '2026-10-21T18:20:40',
        }),
        throwsFormatException,
      );
    });
  });

  group('PontoDoAplicadorDto', () {
    test('campo obrigatório ausente vira FormatException com o nome', () {
      for (final campo in [
        'id',
        'identificador',
        'nome',
        'bairro',
        'endereco',
        'dosagemMl',
        'distanciaEntreSubpontosMetros',
        'quantidadeDeSubpontos',
        'estado',
      ]) {
        final json = _pontoJson()..remove(campo);
        expect(
          () => PontoDoAplicadorDto.fromJson(json),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('"$campo"'),
            ),
          ),
          reason: 'sem $campo',
        );
      }
    });

    test('data agendada inexistente ou fora do formato é recusada', () {
      for (final data in ['2026-02-30', '12/10/2026', '2026-10-12T00:00:00']) {
        final json = _pontoJson(
          extras: {
            'agendamento': {
              'dataInicio': '2026-10-05',
              'intervaloDias': 7,
              'quantidadeRecorrencias': 1,
              'datas': [
                {'id': 'd', 'data': data, 'status': 'PENDENTE'},
              ],
            },
          },
        );
        expect(() => PontoDoAplicadorDto.fromJson(json), throwsFormatException,
            reason: data);
      }
    });

    test('sem agendamento nem subpontos', () {
      final dto = PontoDoAplicadorDto.fromJson(
        _pontoJson(extras: {'agendamento': null, 'subpontos': null}),
      );

      expect(dto.agendamento, isNull);
      expect(dto.subpontos, isEmpty);
    });
  });

  group('SyncMappers.paraPonto', () {
    test('converte o ponto, a recorrência com ids do servidor e os subpontos', () {
      final ponto = SyncMappers.paraPonto(
        PontoDoAplicadorDto.fromJson(_pontoJson()),
      );

      expect(ponto.id, 'p-0001');
      expect(ponto.identificador, 'PA-003');
      expect(ponto.bairro, 'Bela Vista');
      expect(ponto.dosagemMl, 25);
      expect(ponto.quantidadeDeSubpontos, 6);
      expect(ponto.aplicadorId, 'u-0003');
      expect(ponto.estado, EstadoPontoDeAplicacao.ativa);
      expect(ponto.estadoAnterior, EstadoPontoDeAplicacao.direcionada);
      final datas = ponto.agendamento!.datas;
      expect(datas.map((d) => d.id), ['d-0001', 'd-0002', 'd-0003']);
      expect(datas.map((d) => d.status), [
        StatusDataAgendada.concluida,
        StatusDataAgendada.pendente,
        StatusDataAgendada.cancelada,
      ]);
      expect(datas.first.data, DateTime(2026, 10, 5));
      final subponto = ponto.subpontos.single;
      expect(subponto.id, 's-0001');
      expect(subponto.latitude, -26.9317);
      expect(subponto.realizadoEm.toUtc(), DateTime.utc(2026, 10, 12, 17, 30));
      expect(subponto.registradoEm.toUtc(), DateTime.utc(2026, 10, 12, 18, 5, 12));
    });

    test('campos opcionais ausentes ficam vazios e as medidas em zero', () {
      final ponto = SyncMappers.paraPonto(
        PontoDoAplicadorDto.fromJson(_pontoJson()),
      );

      expect(ponto.numeroReferencia, '45');
      expect(ponto.descricaoDoTrecho, isEmpty);
      expect(ponto.larguraMetros, 0);
      expect(ponto.profundidadeMetros, 0);
      expect(ponto.velocidadeMetrosPorSegundo, 0);
      expect(ponto.vazao, 0);
    });

    test('estado ou status desconhecidos viram FormatException', () {
      expect(
        () => SyncMappers.paraPonto(
          PontoDoAplicadorDto.fromJson(_pontoJson(extras: {'estado': 'LIVRE'})),
        ),
        throwsFormatException,
      );
      final json = _pontoJson();
      ((json['agendamento'] as Map)['datas'] as List)[0] = {
        'id': 'd-0001',
        'data': '2026-10-05',
        'status': 'TALVEZ',
      };
      expect(
        () => SyncMappers.paraPonto(PontoDoAplicadorDto.fromJson(json)),
        throwsFormatException,
      );
    });

    test('ponto direcionado sem datas nem subpontos', () {
      final ponto = SyncMappers.paraPonto(
        PontoDoAplicadorDto.fromJson(
          _pontoJson(
            extras: {
              'estado': 'DIRECIONADA',
              'estadoAnterior': null,
              'agendamento': null,
              'subpontos': <Map<String, dynamic>>[],
            },
          ),
        ),
      );

      expect(ponto.estado, EstadoPontoDeAplicacao.direcionada);
      expect(ponto.agendamento, isNull);
      expect(ponto.subpontos, isEmpty);
    });
  });

  group('marca de conflito do subponto (GEOPRAG-207)', () {
    Map<String, dynamic> subpontoJson(Map<String, dynamic> extras) => {
      'id': 's-0009',
      'latitude': -26.9,
      'longitude': -48.9,
      'realizadoEm': '2026-10-12T14:30:00-03:00',
      'recebidoEm': '2026-10-12T18:05:12+00:00',
      ...extras,
    };

    Subponto converter(Map<String, dynamic> extras) =>
        SyncMappers.paraSubponto(SubpontoDto.fromJson(subpontoJson(extras)));

    test('sem os campos (pull do aplicador) é um subponto sem conflito', () {
      final subponto = converter({});

      expect(subponto.conflito, isFalse);
      expect(subponto.motivoConflito, isNull);
    });

    test('conflito false com motivo nulo, como o servidor devolve no normal', () {
      final subponto = converter({'conflito': false, 'motivoConflito': null});

      expect(subponto.conflito, isFalse);
      expect(subponto.motivoConflito, isNull);
    });

    final motivos = {
      'PONTO_REATRIBUIDO': MotivoDeConflito.pontoReatribuido,
      'PONTO_DESATIVADO': MotivoDeConflito.pontoDesativado,
      'PONTO_INATIVO': MotivoDeConflito.pontoInativo,
      'DATA_JA_ATENDIDA': MotivoDeConflito.dataJaAtendida,
      'DATA_CANCELADA': MotivoDeConflito.dataCancelada,
    };
    for (final MapEntry(key: texto, value: motivo) in motivos.entries) {
      test('$texto vira $motivo', () {
        final subponto = converter({
          'conflito': true,
          'motivoConflito': texto,
        });

        expect(subponto.conflito, isTrue);
        expect(subponto.motivoConflito, motivo);
      });
    }

    test('motivo que esta versão não conhece degrada para desconhecido', () {
      final subponto = converter({
        'conflito': true,
        'motivoConflito': 'MOTIVO_NOVO',
      });

      expect(subponto.conflito, isTrue);
      expect(subponto.motivoConflito, MotivoDeConflito.desconhecido);
    });

    test('conflito com tipo errado é recusado como resposta inválida', () {
      expect(
        () => SubpontoDto.fromJson(subpontoJson({'conflito': 'sim'})),
        throwsFormatException,
      );
    });

    test('o ponto inteiro carrega a marca dos subpontos em conflito', () {
      final ponto = SyncMappers.paraPonto(
        PontoDoAplicadorDto.fromJson(
          _pontoJson(
            extras: {
              'subpontos': [
                subpontoJson({'id': 's-ok'}),
                subpontoJson({
                  'id': 's-conflito',
                  'conflito': true,
                  'motivoConflito': 'PONTO_REATRIBUIDO',
                }),
              ],
            },
          ),
        ),
      );

      expect([for (final s in ponto.subpontos) s.conflito], [false, true]);
      expect(
        ponto.subpontos.last.motivoConflito,
        MotivoDeConflito.pontoReatribuido,
      );
    });
  });

  group('SyncMappers.itensDaAplicacao / loteDeAplicacoes', () {
    Aplicacao aplicacao(String id, List<String> subpontos) => Aplicacao(
      id: id,
      pontoId: 'p-0001',
      aplicadorId: 'u-0003',
      dataAgendadaId: 'd-0002',
      produtoId: 'pr-0001',
      realizadoEm: DateTime.utc(2026, 10, 12, 17, 30),
      localizacao: const LocalizacaoCapturada(latitude: 1, longitude: 2),
      subpontos: [
        for (final s in subpontos)
          Subponto(
            id: s,
            latitude: -26.93,
            longitude: -48.95,
            realizadoEm: DateTime.utc(2026, 10, 12, 17, 31),
            registradoEm: DateTime.utc(2026, 10, 12, 17, 31),
          ),
      ],
    );

    test('um item por subponto, herdando os ids da aplicação', () {
      final itens = SyncMappers.itensDaAplicacao(aplicacao('a1', ['s1', 's2']));

      expect(itens.map((i) => i.id), ['s1', 's2']);
      expect(itens.every((i) => i.aplicacaoId == 'a1'), isTrue);
      expect(itens.every((i) => i.pontoId == 'p-0001'), isTrue);
      expect(itens.every((i) => i.dataAgendadaId == 'd-0002'), isTrue);
      expect(itens.every((i) => i.produtoId == 'pr-0001'), isTrue);
      expect(itens.first.latitude, -26.93);
    });

    test('aplicação sem subpontos não gera item', () {
      expect(SyncMappers.itensDaAplicacao(aplicacao('a1', [])), isEmpty);
    });

    test('o lote reúne as aplicações na ordem, com o dispositivo', () {
      final lote = SyncMappers.loteDeAplicacoes(
        dispositivoId: 'aparelho-0001',
        aplicacoes: [aplicacao('a1', ['s1']), aplicacao('a2', ['s2', 's3'])],
      );

      expect(lote.dispositivoId, 'aparelho-0001');
      expect(lote.itens.map((i) => '${i.aplicacaoId}/${i.id}'), [
        'a1/s1',
        'a2/s2',
        'a2/s3',
      ]);
    });

    test('o item gerado serializa para o JSON do contrato', () {
      final item = SyncMappers.itensDaAplicacao(aplicacao('a1', ['s1'])).single;

      final json = item.toJson();

      expect(json.keys.toSet(), {
        'id',
        'aplicacaoId',
        'pontoId',
        'dataAgendadaId',
        'produtoId',
        'latitude',
        'longitude',
        'realizadoEm',
      });
      expect(json['realizadoEm'], '2026-10-12T17:31:00+00:00');
    });
  });
}
