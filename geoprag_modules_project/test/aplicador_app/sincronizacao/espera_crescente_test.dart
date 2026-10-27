import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/sincronizacao/sincronizacao.dart';

void main() {
  test('dobra a cada falha, a partir de 5 s', () {
    final espera = EsperaCrescente();

    expect(
      [for (var i = 0; i < 4; i++) espera.proxima()],
      [
        const Duration(seconds: 5),
        const Duration(seconds: 10),
        const Duration(seconds: 20),
        const Duration(seconds: 40),
      ],
    );
  });

  test('para de crescer na espera máxima (5 min)', () {
    final espera = EsperaCrescente();

    final esperas = [for (var i = 0; i < 40; i++) espera.proxima()];

    expect(esperas.last, const Duration(minutes: 5));
    expect(esperas.where((e) => e > const Duration(minutes: 5)), isEmpty);
  });

  test('reiniciar volta à espera inicial', () {
    final espera = EsperaCrescente();
    espera.proxima();
    espera.proxima();

    espera.reiniciar();

    expect(espera.proxima(), const Duration(seconds: 5));
  });

  test('aceita espera inicial e máxima próprias', () {
    final espera = EsperaCrescente(
      inicial: const Duration(seconds: 1),
      maxima: const Duration(seconds: 3),
    );

    expect(
      [for (var i = 0; i < 4; i++) espera.proxima()],
      [
        const Duration(seconds: 1),
        const Duration(seconds: 2),
        const Duration(seconds: 3),
        const Duration(seconds: 3),
      ],
    );
  });
}
