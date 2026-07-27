import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/application_points/data/mock_pontos_de_aplicacao.dart';
import 'package:geoprag_modules/aplicador_app/application_points/data/ponto_de_aplicacao_repository_impl.dart';

void main() {
  late PontoDeAplicacaoRepositoryImpl repository;

  setUp(() {
    repository = PontoDeAplicacaoRepositoryImpl();
  });

  test('buscarAtual retorna o ponto mockado atual', () async {
    final result = await repository.buscarAtual();

    expect(result.id, mockPontoDeAplicacaoAtual.id);
    expect(result.nomeTrecho, mockPontoDeAplicacaoAtual.nomeTrecho);
    expect(result.status, mockPontoDeAplicacaoAtual.status);
  });

  test('capturarLocalizacaoAtual retorna a leitura de GPS mockada', () async {
    final result = await repository.capturarLocalizacaoAtual();

    expect(result.latitude, mockCapturaLocalizacaoAtual.latitude);
    expect(result.longitude, mockCapturaLocalizacaoAtual.longitude);
    expect(result.precisaoMetros, mockCapturaLocalizacaoAtual.precisaoMetros);
  });

  test('marcarPontoInicial completa sem lançar exceção', () async {
    final ponto = await repository.capturarLocalizacaoAtual();

    await expectLater(repository.marcarPontoInicial(ponto), completes);
  });
}
