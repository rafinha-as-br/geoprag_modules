import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/geoprag_modules.dart';

/// Smoke test do barrel público do pacote: garante que `geoprag_modules.dart`
/// continua exportando (sem quebrar em tempo de análise) pelo menos um tipo
/// de cada árvore principal (`aplicador_app`, `portal_administrador`, `src`).
/// Cobertura de comportamento fica nos testes de cada módulo em
/// `test/aplicador_app/**` e `test/portal_administrador/**`.
void main() {
  test('o barrel público exporta os pontos de entrada esperados', () {
    expect(AplicadorNavigatorScope, isNotNull);
    expect(AdminNavigatorScope, isNotNull);
    expect(GeopragColors.green900, isNotNull);
  });
}
