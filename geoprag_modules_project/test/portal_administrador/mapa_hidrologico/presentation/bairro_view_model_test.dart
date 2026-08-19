import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/core/bairro.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/core/corrego.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/bairro_view_model.dart';

void main() {
  const bairro = Bairro(
    id: 'b1',
    nome: 'Belchior',
    status: 'atrasado',
    diasSemAplicacao: 25,
    corregoIds: ['s1'],
  );

  const corrego = Corrego(
    id: 's1',
    nome: 'Córrego Belchior',
    bairro: 'Belchior',
    largura: 2.5,
    profundidade: 0.5,
    velocidade: 1.2,
  );

  group('BairroResumoViewModel.fromEntity', () {
    test('mapeia todos os campos sem alteração', () {
      final viewModel = BairroResumoViewModel.fromEntity(bairro);

      expect(viewModel.id, 'b1');
      expect(viewModel.nome, 'Belchior');
      expect(viewModel.status, 'atrasado');
      expect(viewModel.diasSemAplicacao, 25);
    });
  });

  group('BairroDetalhadoViewModel.fromEntity', () {
    test('mapeia o bairro e os córregos agregados', () {
      final viewModel = BairroDetalhadoViewModel.fromEntity(bairro, [corrego]);

      expect(viewModel.id, 'b1');
      expect(viewModel.status, 'atrasado');
      expect(viewModel.corregos, hasLength(1));
      expect(viewModel.corregos.first.nome, 'Córrego Belchior');
    });

    test('corregos fica vazio quando não há córregos vinculados', () {
      final viewModel = BairroDetalhadoViewModel.fromEntity(bairro, []);
      expect(viewModel.corregos, isEmpty);
    });
  });
}
