import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/inventory/core/recebimento.dart';
import 'package:geoprag_modules/aplicador_app/inventory/presentation/recebimento_view_model.dart';

void main() {
  final entity = Recebimento(
    id: 'r1',
    produtoNome: 'BTI Líquido',
    quantidadeDescricao: '1 Litro',
    agenteEntregador: 'João Silva',
    cargoAgenteEntregador: 'Fiscal de Agricultura',
    dataDespacho: DateTime(2026, 7, 5, 14, 30),
    status: RecebimentoStatus.pendente,
  );

  group('RecebimentoResumoViewModel.fromEntity', () {
    test('mapeia id, produto e quantidade sem alteração', () {
      final viewModel = RecebimentoResumoViewModel.fromEntity(entity);

      expect(viewModel.id, 'r1');
      expect(viewModel.produtoNome, 'BTI Líquido');
      expect(viewModel.quantidadeDescricao, '1 Litro');
    });

    test('formata enviadoPorDescricao com nome e cargo do agente', () {
      final viewModel = RecebimentoResumoViewModel.fromEntity(entity);

      expect(
        viewModel.enviadoPorDescricao,
        'Enviado por: João Silva (Fiscal de Agricultura)',
      );
    });

    test('formata dataDescricao como "Data: dd/MM/yyyy"', () {
      final viewModel = RecebimentoResumoViewModel.fromEntity(entity);

      expect(viewModel.dataDescricao, 'Data: 05/07/2026');
    });

    test('tituloProduto combina produto e quantidade', () {
      final viewModel = RecebimentoResumoViewModel.fromEntity(entity);

      expect(viewModel.tituloProduto, 'BTI Líquido - 1 Litro');
    });
  });

  group('RecebimentoDetalheViewModel.fromEntity', () {
    test('mapeia id, produto e quantidade sem alteração', () {
      final viewModel = RecebimentoDetalheViewModel.fromEntity(entity);

      expect(viewModel.id, 'r1');
      expect(viewModel.produtoNome, 'BTI Líquido');
      expect(viewModel.quantidadeDescricao, '1 Litro');
    });

    test('formata agenteEntregadorDescricao com nome e cargo', () {
      final viewModel = RecebimentoDetalheViewModel.fromEntity(entity);

      expect(
        viewModel.agenteEntregadorDescricao,
        'João Silva (Fiscal de Agricultura)',
      );
    });

    test('formata dataDespachoDescricao com data e hora (dd/MM/yyyy às HH:mm)', () {
      final viewModel = RecebimentoDetalheViewModel.fromEntity(entity);

      expect(viewModel.dataDespachoDescricao, '05/07/2026 às 14:30');
    });

    test('tituloProduto combina produto e quantidade', () {
      final viewModel = RecebimentoDetalheViewModel.fromEntity(entity);

      expect(viewModel.tituloProduto, 'BTI Líquido - 1 Litro');
    });
  });
}
