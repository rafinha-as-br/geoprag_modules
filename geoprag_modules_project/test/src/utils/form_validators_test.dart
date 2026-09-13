import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/utils/form_validators.dart';

void main() {
  group('formatarNumeroExibicao', () {
    test('exibe inteiro sem casas decimais', () {
      expect(formatarNumeroExibicao(2), '2');
      expect(formatarNumeroExibicao(2.0), '2');
    });

    test('exibe decimal limpo sem zeros artificiais', () {
      expect(formatarNumeroExibicao(0.7), '0.7');
    });

    test(
      'arredonda ruído de ponto flutuante em vez de expor o double bruto '
      '— regressão GEOPRAG-38/QA (vazão 2.2 × 0.7 × 0.3)',
      () {
        final vazao = 2.2 * 0.7 * 0.3;
        expect(vazao.toString(), '0.46199999999999997');
        expect(formatarNumeroExibicao(vazao), '0.462');
      },
    );
  });
}
