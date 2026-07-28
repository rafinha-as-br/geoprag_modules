import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/application_points/core/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/aplicador_app/application_points/presentation/ponto_de_aplicacao_view_model.dart';

void main() {
  final entity = PontoDeAplicacao(
    id: '1',
    nomeTrecho: 'Córrego Gasparinho - Trecho 01',
    referencia: 'Rua Pedro Simon, Margem Esquerda',
    latitude: -26.9312,
    longitude: -48.9567,
    precisaoMetros: 4,
    status: 'no_prazo',
    dataUltimaAplicacao: DateTime(2026, 5, 10),
    dataProximaAplicacaoEstimada: DateTime(2026, 5, 25),
  );

  group('PontoDeAplicacaoViewModel.fromEntity', () {
    test('mapeia todos os campos da entidade sem perda de dados', () {
      final viewModel = PontoDeAplicacaoViewModel.fromEntity(entity);

      expect(viewModel.nomeTrecho, entity.nomeTrecho);
      expect(viewModel.referencia, entity.referencia);
      expect(viewModel.dataUltimaAplicacao, entity.dataUltimaAplicacao);
      expect(
        viewModel.dataProximaAplicacaoEstimada,
        entity.dataProximaAplicacaoEstimada,
      );
    });

    test('estaNoPrazo é true quando status == "no_prazo"', () {
      final viewModel = PontoDeAplicacaoViewModel.fromEntity(entity);
      expect(viewModel.estaNoPrazo, isTrue);
    });

    test('estaNoPrazo é false para qualquer outro status (ex: "atrasado")', () {
      final atrasado = PontoDeAplicacao(
        id: entity.id,
        nomeTrecho: entity.nomeTrecho,
        referencia: entity.referencia,
        latitude: entity.latitude,
        longitude: entity.longitude,
        precisaoMetros: entity.precisaoMetros,
        status: 'atrasado',
        dataUltimaAplicacao: entity.dataUltimaAplicacao,
        dataProximaAplicacaoEstimada: entity.dataProximaAplicacaoEstimada,
      );

      expect(PontoDeAplicacaoViewModel.fromEntity(atrasado).estaNoPrazo, isFalse);
    });

    test('datas formatadas seguem o padrão dd/MM/yyyy', () {
      final viewModel = PontoDeAplicacaoViewModel.fromEntity(entity);

      expect(viewModel.dataUltimaAplicacaoFormatada, '10/05/2026');
      expect(viewModel.dataProximaAplicacaoEstimadaFormatada, '25/05/2026');
    });

    test('preenche os dias/meses com zero à esquerda quando < 10', () {
      final viewModel = PontoDeAplicacaoViewModel(
        nomeTrecho: entity.nomeTrecho,
        referencia: entity.referencia,
        estaNoPrazo: true,
        dataUltimaAplicacao: DateTime(2026, 1, 5),
        dataProximaAplicacaoEstimada: DateTime(2026, 1, 5),
      );

      expect(viewModel.dataUltimaAplicacaoFormatada, '05/01/2026');
    });
  });

  group('CapturaLocalizacaoViewModel.fromEntity', () {
    test('mapeia latitude, longitude e precisão da entidade', () {
      final viewModel = CapturaLocalizacaoViewModel.fromEntity(entity);

      expect(viewModel.latitude, entity.latitude);
      expect(viewModel.longitude, entity.longitude);
      expect(viewModel.precisaoMetros, entity.precisaoMetros);
    });

    test('qualidadePrecisao é "Alta" quando precisão < 10m', () {
      final viewModel = CapturaLocalizacaoViewModel(
        latitude: 0,
        longitude: 0,
        precisaoMetros: 4,
      );
      expect(viewModel.qualidadePrecisao, 'Alta');
    });

    test('qualidadePrecisao é "Média" quando precisão entre 10m e 30m', () {
      final viewModel = CapturaLocalizacaoViewModel(
        latitude: 0,
        longitude: 0,
        precisaoMetros: 15,
      );
      expect(viewModel.qualidadePrecisao, 'Média');
    });

    test('qualidadePrecisao é "Baixa" quando precisão >= 30m', () {
      final viewModel = CapturaLocalizacaoViewModel(
        latitude: 0,
        longitude: 0,
        precisaoMetros: 42,
      );
      expect(viewModel.qualidadePrecisao, 'Baixa');
    });

    test('coordenadasFormatadas usa 4 casas decimais separadas por vírgula', () {
      final viewModel = CapturaLocalizacaoViewModel(
        latitude: -26.9312,
        longitude: -48.9567,
        precisaoMetros: 4,
      );
      expect(viewModel.coordenadasFormatadas, '-26.9312, -48.9567');
    });
  });
}
