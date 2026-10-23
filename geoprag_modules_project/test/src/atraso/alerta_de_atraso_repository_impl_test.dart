import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/atraso/alerta_de_atraso_repository_impl.dart';

void main() {
  tearDown(mockAlertasDeAtrasoRemovidos.clear);

  test('sem remoção, o ponto não tem alerta removido', () async {
    expect(
      await AlertaDeAtrasoRepositoryImpl().listarRemovidos('pa1'),
      isEmpty,
    );
  });

  test('remover guarda a recorrência só para aquele ponto', () async {
    await AlertaDeAtrasoRepositoryImpl().remover(
      pontoId: 'pa1',
      dataAgendadaId: '2026-10-01-0',
    );

    expect(await AlertaDeAtrasoRepositoryImpl().listarRemovidos('pa1'), {
      '2026-10-01-0',
    });
    expect(
      await AlertaDeAtrasoRepositoryImpl().listarRemovidos('pa2'),
      isEmpty,
    );
  });

  test('remover a mesma recorrência duas vezes é idempotente', () async {
    final repository = AlertaDeAtrasoRepositoryImpl();
    for (var i = 0; i < 2; i++) {
      await repository.remover(pontoId: 'pa1', dataAgendadaId: 'd0');
    }

    expect(await repository.listarRemovidos('pa1'), {'d0'});
  });
}
