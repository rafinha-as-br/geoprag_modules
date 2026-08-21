import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/validators/ponto_de_aplicacao_validators.dart';

void main() {
  group('PontoDeAplicacaoValidators.distanciaAlertaMetros', () {
    test('rejeita valor vazio', () {
      expect(
        PontoDeAplicacaoValidators.distanciaAlertaMetros(''),
        'Informe a distância.',
      );
    });

    test('rejeita valor não numérico', () {
      expect(
        PontoDeAplicacaoValidators.distanciaAlertaMetros('abc'),
        'Distância inválida.',
      );
    });

    test('rejeita zero e negativos', () {
      expect(
        PontoDeAplicacaoValidators.distanciaAlertaMetros('0'),
        'Distância deve ser maior que zero.',
      );
      expect(
        PontoDeAplicacaoValidators.distanciaAlertaMetros('-10'),
        'Distância deve ser maior que zero.',
      );
    });

    test('aceita valor positivo', () {
      expect(
        PontoDeAplicacaoValidators.distanciaAlertaMetros('150'),
        isNull,
      );
    });
  });

  group('PontoDeAplicacaoValidators.intervaloDiasEntreAplicacoes', () {
    test('rejeita valor vazio', () {
      expect(
        PontoDeAplicacaoValidators.intervaloDiasEntreAplicacoes(''),
        'Informe o intervalo.',
      );
    });

    test('rejeita valor não numérico ou decimal', () {
      expect(
        PontoDeAplicacaoValidators.intervaloDiasEntreAplicacoes('abc'),
        'Intervalo inválido.',
      );
      expect(
        PontoDeAplicacaoValidators.intervaloDiasEntreAplicacoes('15.5'),
        'Intervalo inválido.',
      );
    });

    test('rejeita zero e negativos', () {
      expect(
        PontoDeAplicacaoValidators.intervaloDiasEntreAplicacoes('0'),
        'Intervalo deve ser maior que zero.',
      );
      expect(
        PontoDeAplicacaoValidators.intervaloDiasEntreAplicacoes('-5'),
        'Intervalo deve ser maior que zero.',
      );
    });

    test('aceita valor inteiro positivo', () {
      expect(
        PontoDeAplicacaoValidators.intervaloDiasEntreAplicacoes('15'),
        isNull,
      );
    });
  });
}
