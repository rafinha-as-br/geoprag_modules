import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/local/local.dart';
import 'package:geoprag_modules/src/api/sync/registro_dtos.dart';

import 'apoio_do_banco.dart';

void main() {
  final registro = ItemDeRegistroDto(
    id: 's-1',
    aplicacaoId: 'app-1',
    pontoId: 'ponto-9',
    dataAgendadaId: 'd-1',
    produtoId: 'produto-1',
    latitude: -26.9,
    longitude: -48.9,
    realizadoEm: DateTime.utc(2026, 10, 20, 12),
  );

  group('ItemDaOutbox.paraSubponto', () {
    test('usa o id do subponto, nasce PENDENTE e guarda o ponto', () {
      final item = ItemDaOutbox.paraSubponto(registro, criadoEm: agoraDeTeste);

      expect(item.id, 's-1');
      expect(item.pontoId, 'ponto-9');
      expect(item.tipo, TipoDoItemDaOutbox.subponto);
      expect(item.estado, EstadoDoItemDaOutbox.pendente);
      expect(item.tentativas, 0);
    });

    test('o payload é o JSON do contrato de POST /sync/aplicacoes', () {
      final item = ItemDaOutbox.paraSubponto(registro, criadoEm: agoraDeTeste);

      final json = jsonDecode(item.payload) as Map<String, dynamic>;

      expect(ItemDeRegistroDto.fromJson(json), registro);
    });
  });

  test('toString não expõe o payload', () {
    final item = ItemDaOutbox.paraSubponto(registro, criadoEm: agoraDeTeste);

    expect(item.toString(), isNot(contains('-26.9')));
    expect(item.toString(), contains('s-1'));
  });

  test('itens com os mesmos dados são iguais', () {
    final a = ItemDaOutbox.paraSubponto(registro, criadoEm: agoraDeTeste);
    final b = ItemDaOutbox.paraSubponto(registro, criadoEm: agoraDeTeste);

    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });

  group('valores guardados no banco', () {
    test('estados e tipos fazem a viagem de ida e volta', () {
      for (final estado in EstadoDoItemDaOutbox.values) {
        expect(EstadoDoItemDaOutbox.doValor(estado.valor), estado);
      }
      for (final tipo in TipoDoItemDaOutbox.values) {
        expect(TipoDoItemDaOutbox.doValor(tipo.valor), tipo);
      }
    });

    test('valor desconhecido vira FormatException', () {
      expect(() => EstadoDoItemDaOutbox.doValor('X'), throwsFormatException);
      expect(() => TipoDoItemDaOutbox.doValor('X'), throwsFormatException);
    });
  });
}
