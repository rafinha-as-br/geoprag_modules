import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/applications/data/aplicacao_repository_impl.dart';
import 'package:geoprag_modules/aplicador_app/applications/data/mock_aplicacoes.dart';

void main() {
  late AplicacaoRepositoryImpl repository;

  setUp(() {
    repository = AplicacaoRepositoryImpl();
  });

  test('buscarAtual retorna a primeira aplicação mockada do aplicador informado', () async {
    final result = await repository.buscarAtual('1');

    expect(result.aplicadorId, '1');
    expect(result.id, mockApplications.firstWhere((a) => a.aplicadorId == '1').id);
  });

  test('buscarAtual lança StateError quando o aplicador não tem aplicação em mockApplications', () {
    expect(
      () => repository.buscarAtual('inexistente'),
      throwsA(isA<StateError>()),
    );
  });
}
