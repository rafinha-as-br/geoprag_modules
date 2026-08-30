import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/data/licitacao_repository_impl.dart';
import 'package:geoprag_modules/portal_administrador/inventory_and_bidding/data/mock_licitacoes.dart';

void main() {
  late LicitacaoRepositoryImpl repository;

  setUp(() {
    repository = LicitacaoRepositoryImpl();
  });

  test('listar retorna todas as licitações mockadas', () async {
    final result = await repository.listar();
    expect(result.length, mockLicitacoes.length);
  });

  test('criar adiciona a licitação à lista mockada e a retorna', () async {
    final antes = mockLicitacoes.length;

    final licitacao = await repository.criar(
      numeroAno: 'Pregão 03/2026',
      fornecedorVencedor: 'Nova Fornecedora Ltda.',
      objetoLicitado: 'Aquisição de EPI',
      valorTotal: 15000,
      dataHomologacao: DateTime(2026, 8, 1),
    );

    expect(licitacao.numeroAno, 'Pregão 03/2026');
    expect(mockLicitacoes.length, antes + 1);
    expect(mockLicitacoes.last, same(licitacao));
  });
}
