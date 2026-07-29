import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/core/corrego.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/corrego_view_model.dart';

void main() {
  const corrego = Corrego(
    id: 's1',
    nome: 'Córrego Belchior',
    bairro: 'Belchior',
    largura: 2.5,
    profundidade: 0.5,
    velocidade: 1.2,
  );

  group('CorregoResumoViewModel.fromEntity', () {
    test('mapeia id, nome e bairro sem alteração', () {
      final viewModel = CorregoResumoViewModel.fromEntity(corrego);

      expect(viewModel.id, 's1');
      expect(viewModel.nome, 'Córrego Belchior');
      expect(viewModel.bairro, 'Belchior');
    });
  });

  group('CorregoDetalhadoViewModel.fromEntity', () {
    test('mapeia todas as medições físicas sem alteração', () {
      final viewModel = CorregoDetalhadoViewModel.fromEntity(corrego);

      expect(viewModel.largura, 2.5);
      expect(viewModel.profundidade, 0.5);
      expect(viewModel.velocidade, 1.2);
    });
  });
}
