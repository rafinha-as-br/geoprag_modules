import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/geoprag_modules.dart';

void main() {
  final realizadoEmUtc = DateTime.utc(2026, 10, 21, 17, 30);

  ItemDeRegistroDto item({DateTime? realizadoEm}) => ItemDeRegistroDto(
    id: '3f2b8c1e-5a4d-4e0a-9d6b-1c2d3e4f5a6b',
    aplicacaoId: '7a9c0d2e-1b3f-4a5c-8e6d-0f1a2b3c4d5e',
    pontoId: 'p-0001',
    dataAgendadaId: 'd-0001',
    produtoId: 'pr-0001',
    latitude: -26.9317,
    longitude: -48.9589,
    realizadoEm: realizadoEm ?? realizadoEmUtc,
  );

  group('ItemDeRegistroDto', () {
    test('toJson segue o contrato v0 (data e hora com offset)', () {
      expect(item().toJson(), {
        'id': '3f2b8c1e-5a4d-4e0a-9d6b-1c2d3e4f5a6b',
        'aplicacaoId': '7a9c0d2e-1b3f-4a5c-8e6d-0f1a2b3c4d5e',
        'pontoId': 'p-0001',
        'dataAgendadaId': 'd-0001',
        'produtoId': 'pr-0001',
        'latitude': -26.9317,
        'longitude': -48.9589,
        'realizadoEm': '2026-10-21T17:30:00+00:00',
      });
    });

    test('um instante local vai com o offset do próprio aparelho', () {
      final local = DateTime(2026, 10, 21, 14, 30);
      final offset = local.timeZoneOffset;
      final sinal = offset.isNegative ? '-' : '+';
      final hh = offset.inHours.abs().toString().padLeft(2, '0');
      final mm = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');

      expect(
        item(realizadoEm: local).toJson()['realizadoEm'],
        '2026-10-21T14:30:00$sinal$hh:$mm',
      );
    });

    test('ida e volta preserva o instante', () {
      final original = item(realizadoEm: DateTime(2026, 10, 21, 14, 30, 5));

      final lido = ItemDeRegistroDto.fromJson(original.toJson());

      expect(lido, original);
      expect(lido.realizadoEm.isAtSameMomentAs(original.realizadoEm), isTrue);
    });

    test('lê data e hora com offset negativo', () {
      final lido = ItemDeRegistroDto.fromJson({
        ...item().toJson(),
        'realizadoEm': '2026-10-21T14:30:00-03:00',
      });

      expect(lido.realizadoEm.toUtc(), DateTime.utc(2026, 10, 21, 17, 30));
    });

    test('data e hora sem offset é recusada (instante ambíguo)', () {
      expect(
        () => ItemDeRegistroDto.fromJson({
          ...item().toJson(),
          'realizadoEm': '2026-10-21T14:30:00',
        }),
        throwsFormatException,
      );
    });

    test('campo ausente ou de tipo errado vira FormatException', () {
      for (final campo in item().toJson().keys) {
        final json = {...item().toJson()}..remove(campo);
        expect(() => ItemDeRegistroDto.fromJson(json), throwsFormatException,
            reason: 'sem $campo');
      }
      expect(
        () => ItemDeRegistroDto.fromJson({...item().toJson(), 'latitude': '1'}),
        throwsFormatException,
      );
    });
  });

  group('LoteDeRegistroDto', () {
    test('serializa dispositivoId e os itens na ordem', () {
      final lote = LoteDeRegistroDto(
        dispositivoId: 'aparelho-0001',
        itens: [item(), item(realizadoEm: DateTime.utc(2026, 10, 22))],
      );

      final json = lote.toJson();

      expect(json['dispositivoId'], 'aparelho-0001');
      expect((json['itens'] as List).length, 2);
      expect(
        ((json['itens'] as List).last as Map)['realizadoEm'],
        '2026-10-22T00:00:00+00:00',
      );
    });
  });

  group('RespostaDoLoteDto', () {
    test('lê um resultado por item, na ordem, com rejeição detalhada', () {
      final resposta = RespostaDoLoteDto.fromJson({
        'recebidoEm': '2026-10-21T18:05:12-03:00',
        'resultados': [
          {'id': 'a', 'status': 'CRIADO'},
          {'id': 'b', 'status': 'DUPLICADO'},
          {
            'id': 'c',
            'status': 'REJEITADO',
            'codigo': 'PONTO_INEXISTENTE',
            'motivo': 'O ponto informado não existe para o tenant.',
          },
        ],
      });

      expect(resposta.resultados.map((r) => r.id), ['a', 'b', 'c']);
      expect(resposta.resultados.map((r) => r.status), [
        StatusItemDto.criado,
        StatusItemDto.duplicado,
        StatusItemDto.rejeitado,
      ]);
      expect(resposta.resultados.map((r) => r.status.entregue), [
        true,
        true,
        false,
      ]);
      expect(resposta.resultados.last.codigo, 'PONTO_INEXISTENTE');
      expect(resposta.resultados.last.motivo, contains('não existe'));
      expect(resposta.resultados.first.codigo, isNull);
      expect(
        resposta.recebidoEm.toUtc(),
        DateTime.utc(2026, 10, 21, 21, 5, 12),
      );
    });

    test('status desconhecido ou campo ausente vira FormatException', () {
      expect(
        () => RespostaDoLoteDto.fromJson({
          'recebidoEm': '2026-10-21T18:05:12-03:00',
          'resultados': [
            {'id': 'a', 'status': 'TALVEZ'},
          ],
        }),
        throwsFormatException,
      );
      expect(
        () => RespostaDoLoteDto.fromJson({
          'recebidoEm': '2026-10-21T18:05:12-03:00',
        }),
        throwsFormatException,
      );
    });
  });
}
