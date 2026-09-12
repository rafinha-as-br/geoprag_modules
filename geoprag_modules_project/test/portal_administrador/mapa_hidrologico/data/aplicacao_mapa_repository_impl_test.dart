import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/data/mock_aplicacoes.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/data/aplicacao_mapa_repository_impl.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';

void main() {
  late AplicacaoMapaRepositoryImpl repository;

  setUp(() {
    repository = AplicacaoMapaRepositoryImpl();
  });

  test('buscarPorId retorna a aplicação correspondente', () async {
    final esperado = mockApplications.first;

    final result = await repository.buscarPorId(esperado.id);

    expect(result.id, esperado.id);
    expect(result.aplicadorId, esperado.aplicadorId);
  });

  test('buscarPorId lança EntidadeNaoEncontradaException quando o id não existe', () {
    expect(
      () => repository.buscarPorId('inexistente'),
      throwsA(isA<EntidadeNaoEncontradaException>()),
    );
  });
}
