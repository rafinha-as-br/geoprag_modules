import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/inventory/core/insumo.dart';
import 'package:geoprag_modules/aplicador_app/inventory/presentation/insumo_view_model.dart';

void main() {
  group('EstoqueAtualViewModel.fromEntity', () {
    test('mapeia o nome do produto e a contagem de pendentes', () {
      final insumo = Insumo(
        id: '1',
        nome: 'BTI Líquido',
        quantidadeEmEstoque: 950,
        unidadeMedida: 'ml',
        dataUltimaAtualizacao: DateTime.now(),
      );

      final viewModel = EstoqueAtualViewModel.fromEntity(insumo, 2);

      expect(viewModel.produtoNome, 'BTI Líquido');
      expect(viewModel.recebimentosPendentesCount, 2);
    });

    test('formata quantidade inteira sem casas decimais', () {
      final insumo = Insumo(
        id: '1',
        nome: 'BTI Líquido',
        quantidadeEmEstoque: 950,
        unidadeMedida: 'ml',
        dataUltimaAtualizacao: DateTime.now(),
      );

      expect(
        EstoqueAtualViewModel.fromEntity(insumo, 0).quantidadeFormatada,
        '950 ml',
      );
    });

    test('marca "Última atualização hoje" quando a data é o dia atual', () {
      final insumo = Insumo(
        id: '1',
        nome: 'BTI Líquido',
        quantidadeEmEstoque: 950,
        unidadeMedida: 'ml',
        dataUltimaAtualizacao: DateTime.now(),
      );

      expect(
        EstoqueAtualViewModel.fromEntity(insumo, 0).atualizadoEmDescricao,
        'Última atualização hoje',
      );
    });

    test('formata a data quando a atualização não foi hoje', () {
      final insumo = Insumo(
        id: '2',
        nome: 'BTI Sólido',
        quantidadeEmEstoque: 500,
        unidadeMedida: 'g',
        dataUltimaAtualizacao: DateTime(2026, 5, 1),
      );

      expect(
        EstoqueAtualViewModel.fromEntity(insumo, 0).atualizadoEmDescricao,
        'Última atualização em 01/05/2026',
      );
    });
  });

  group('EstoqueAtualViewModel.recebimentosPendentesDescricao', () {
    final insumo = Insumo(
      id: '1',
      nome: 'BTI Líquido',
      quantidadeEmEstoque: 950,
      unidadeMedida: 'ml',
      dataUltimaAtualizacao: DateTime.now(),
    );

    test('"Nenhum produto a caminho" quando count == 0', () {
      expect(
        EstoqueAtualViewModel.fromEntity(insumo, 0).recebimentosPendentesDescricao,
        'Nenhum produto a caminho',
      );
    });

    test('singular ("1 produto a caminho") quando count == 1', () {
      expect(
        EstoqueAtualViewModel.fromEntity(insumo, 1).recebimentosPendentesDescricao,
        '1 produto a caminho',
      );
    });

    test('plural ("N produtos a caminho") quando count > 1', () {
      expect(
        EstoqueAtualViewModel.fromEntity(insumo, 3).recebimentosPendentesDescricao,
        '3 produtos a caminho',
      );
    });
  });
}
