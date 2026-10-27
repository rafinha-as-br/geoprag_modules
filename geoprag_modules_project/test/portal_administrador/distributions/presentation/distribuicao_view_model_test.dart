import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/distributions/core/distribuicao.dart';
import 'package:geoprag_modules/portal_administrador/distributions/core/produto_referencia_distribuicao.dart';
import 'package:geoprag_modules/portal_administrador/distributions/core/responsavel_referencia_distribuicao.dart';
import 'package:geoprag_modules/portal_administrador/distributions/presentation/distribuicao_view_model.dart';

void main() {
  final entity = Distribuicao(
    id: 'd1',
    produtoId: 'p1',
    quantidade: 2,
    unidade: 'Litros',
    dataEntrega: DateTime(2026, 6, 1),
    responsavel: 'João Silva',
    bairroResponsavel: 'Belchior',
    statusConfirmacao: 'confirmado',
  );

  group('DistribuicaoResumoViewModel.fromEntity', () {
    test('mapeia os campos e formata a data como dd/MM/yyyy', () {
      final viewModel = DistribuicaoResumoViewModel.fromEntity(
        entity,
        'BTI Líquido - Lote L-001',
      );

      expect(viewModel.id, 'd1');
      expect(viewModel.produtoNome, 'BTI Líquido - Lote L-001');
      expect(viewModel.quantidade, 2);
      expect(viewModel.unidade, 'Litros');
      expect(viewModel.responsavel, 'João Silva');
      expect(viewModel.bairroResponsavel, 'Belchior');
      expect(viewModel.dataEntrega, '01/06/2026');
      expect(viewModel.statusConfirmacao, 'confirmado');
    });
  });

  group('DistribuicaoDetalhadaViewModel.fromEntity', () {
    test('mapeia os campos e formata a data como dd/MM/yyyy', () {
      final viewModel = DistribuicaoDetalhadaViewModel.fromEntity(
        entity,
        'BTI Líquido - Lote L-001',
      );

      expect(viewModel.produtoNome, 'BTI Líquido - Lote L-001');
      expect(viewModel.quantidade, 2);
      expect(viewModel.dataEntrega, '01/06/2026');
      expect(viewModel.responsavel, 'João Silva');
      expect(viewModel.statusConfirmacao, 'confirmado');
    });
  });

  group('rotuloConfirmacao', () {
    test('traduz cada status e trata o desconhecido como aguardando', () {
      expect(rotuloConfirmacao('confirmado'), 'recebimento confirmado');
      expect(rotuloConfirmacao('recusado'), 'recebimento recusado');
      expect(
        rotuloConfirmacao('aguardando_aceite'),
        'aguardando confirmação',
      );
    });
  });

  group('ProdutoOpcaoViewModel.fromEntity', () {
    test('mapeia id e nomeExibicao sem alteração', () {
      const produto = ProdutoReferenciaDistribuicao(
        id: 'p1',
        nomeExibicao: 'BTI Líquido - Lote L-001',
      );

      final viewModel = ProdutoOpcaoViewModel.fromEntity(produto);

      expect(viewModel.id, 'p1');
      expect(viewModel.nomeExibicao, 'BTI Líquido - Lote L-001');
    });
  });

  group('ResponsavelOpcaoViewModel.fromEntity', () {
    test('mapeia id, nome e bairro sem alteração', () {
      const responsavel = ResponsavelReferenciaDistribuicao(
        id: '1',
        nome: 'João Silva',
        bairro: 'Belchior',
      );

      final viewModel = ResponsavelOpcaoViewModel.fromEntity(responsavel);

      expect(viewModel.id, '1');
      expect(viewModel.nome, 'João Silva');
      expect(viewModel.bairro, 'Belchior');
    });
  });

  group('DistribuicaoDetalhadaViewModel.confirmadoEm', () {
    test('formata data e hora da confirmação, ou fica nulo sem ela', () {
      final confirmada = Distribuicao(
        id: 'd1',
        produtoId: 'p1',
        quantidade: 2,
        unidade: 'Litros',
        dataEntrega: DateTime(2026, 6, 1),
        responsavel: 'João Silva',
        bairroResponsavel: 'Belchior',
        statusConfirmacao: 'confirmado',
        confirmadoEm: DateTime(2026, 6, 2, 9, 5),
      );

      expect(
        DistribuicaoDetalhadaViewModel.fromEntity(confirmada, 'x').confirmadoEm,
        '02/06/2026 09:05',
      );
      expect(
        DistribuicaoDetalhadaViewModel.fromEntity(entity, 'x').confirmadoEm,
        isNull,
      );
    });
  });
}
