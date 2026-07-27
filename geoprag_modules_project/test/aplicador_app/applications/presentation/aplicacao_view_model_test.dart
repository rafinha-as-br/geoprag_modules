import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/applications/core/aplicacao.dart';
import 'package:geoprag_modules/aplicador_app/applications/presentation/aplicacao_view_model.dart';

void main() {
  group('AplicacaoAtualViewModel.fromEntity', () {
    test('mapeia id e aplicadorId sem alteração', () {
      final entity = Aplicacao(
        id: 'a1',
        data: DateTime(2026, 5, 3),
        lat: -26.9328,
        lng: -48.9554,
        dosagem: 10.5,
        aplicadorId: '1',
      );

      final viewModel = AplicacaoAtualViewModel.fromEntity(entity);

      expect(viewModel.id, 'a1');
      expect(viewModel.aplicadorId, '1');
    });

    test('formata a data como dd/MM/yyyy com zero à esquerda', () {
      final entity = Aplicacao(
        id: 'a1',
        data: DateTime(2026, 1, 5),
        lat: 0,
        lng: 0,
        dosagem: 1,
        aplicadorId: '1',
      );

      expect(AplicacaoAtualViewModel.fromEntity(entity).dataFormatada, '05/01/2026');
    });

    test('formata dosagem inteira sem casas decimais (ex: 10.0 -> "10 ml")', () {
      final entity = Aplicacao(
        id: 'a1',
        data: DateTime(2026, 1, 1),
        lat: 0,
        lng: 0,
        dosagem: 10.0,
        aplicadorId: '1',
      );

      expect(AplicacaoAtualViewModel.fromEntity(entity).dosagemFormatada, '10 ml');
    });

    test('formata dosagem fracionária com 1 casa decimal (ex: 10.5 -> "10.5 ml")', () {
      final entity = Aplicacao(
        id: 'a1',
        data: DateTime(2026, 1, 1),
        lat: 0,
        lng: 0,
        dosagem: 10.5,
        aplicadorId: '1',
      );

      expect(AplicacaoAtualViewModel.fromEntity(entity).dosagemFormatada, '10.5 ml');
    });

    test('formata localização com 4 casas decimais separadas por vírgula', () {
      final entity = Aplicacao(
        id: 'a1',
        data: DateTime(2026, 1, 1),
        lat: -26.9328,
        lng: -48.9554,
        dosagem: 1,
        aplicadorId: '1',
      );

      expect(
        AplicacaoAtualViewModel.fromEntity(entity).localizacaoFormatada,
        '-26.9328, -48.9554',
      );
    });
  });
}
