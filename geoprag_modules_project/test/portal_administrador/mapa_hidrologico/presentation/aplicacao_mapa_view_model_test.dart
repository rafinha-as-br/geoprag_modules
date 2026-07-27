import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/applications/core/aplicacao.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/aplicacao_mapa_view_model.dart';

void main() {
  test('AplicacaoMapaViewModel.fromEntity mapeia todos os campos sem alteração', () {
    final entity = Aplicacao(
      id: 'a1',
      data: DateTime(2026, 5, 3),
      lat: -26.9328,
      lng: -48.9554,
      dosagem: 10.5,
      aplicadorId: '1',
    );

    final viewModel = AplicacaoMapaViewModel.fromEntity(entity);

    expect(viewModel.id, 'a1');
    expect(viewModel.data, entity.data);
    expect(viewModel.lat, entity.lat);
    expect(viewModel.lng, entity.lng);
    expect(viewModel.dosagem, entity.dosagem);
    expect(viewModel.aplicadorId, entity.aplicadorId);
  });
}
