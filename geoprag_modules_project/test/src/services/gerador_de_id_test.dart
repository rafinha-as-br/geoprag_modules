import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/geoprag_modules.dart';

void main() {
  group('GeradorDeIdUuid', () {
    test('gera UUID v4 no formato canônico', () {
      final id = GeradorDeIdUuid().gerar();

      expect(GeradorDeIdUuid.ehUuidV4(id), isTrue, reason: id);
    });

    test('não repete identificadores', () {
      final gerador = GeradorDeIdUuid();

      final ids = {for (var i = 0; i < 2000; i++) gerador.gerar()};

      expect(ids.length, 2000);
    });

    test('ehUuidV4 recusa o que não é UUID v4', () {
      expect(GeradorDeIdUuid.ehUuidV4('sp-teste-1'), isFalse);
      expect(GeradorDeIdUuid.ehUuidV4(''), isFalse);
      // versão 1
      expect(
        GeradorDeIdUuid.ehUuidV4('6ba7b810-9dad-11d1-80b4-00c04fd430c8'),
        isFalse,
      );
      // maiúsculas não são o formato canônico
      expect(
        GeradorDeIdUuid.ehUuidV4('3F2B8C1E-5A4D-4E0A-9D6B-1C2D3E4F5A6B'),
        isFalse,
      );
      expect(
        GeradorDeIdUuid.ehUuidV4('3f2b8c1e-5a4d-4e0a-9d6b-1c2d3e4f5a6b'),
        isTrue,
      );
    });
  });
}
