import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/capacidades_por_cargo.dart';
import 'package:geoprag_modules/src/permissions/capacidade.dart';

void main() {
  test('todo AdminRole tem uma entrada no mapa', () {
    for (final role in AdminRole.values) {
      expect(capacidadesPorCargo.containsKey(role), isTrue, reason: '$role');
    }
  });

  test('toda Capacidade está coberta para os dois cargos (paridade atual)', () {
    for (final role in AdminRole.values) {
      final capacidades = capacidadesPorCargo[role]!;
      for (final capacidade in Capacidade.values) {
        expect(
          capacidades.contains(capacidade),
          isTrue,
          reason: '$role deveria ter $capacidade (paridade total hoje)',
        );
      }
    }
  });
}
