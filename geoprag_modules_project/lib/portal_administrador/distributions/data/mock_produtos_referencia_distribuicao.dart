import '../core/produto_referencia_distribuicao.dart';

/// Nomes de exibição de produtos por `produtoId`, replicados localmente
/// porque o módulo `inventory_and_bidding` (entidade `Produto`) está sendo
/// reconstruído em paralelo e este módulo não deve depender do seu
/// Cubit/Repository.
///
/// TODO(GEOPRAG-24): substituir por uma consulta real ao módulo de estoque
/// (ou ao backend) assim que a agregação entre os dois módulos existir.
final Map<String, String> mockNomesProdutosDistribuicao = {
  'p1': 'BTI Líquido - Lote L-001',
  'p2': 'BTI Granulado - Lote L-002',
  'p3': 'BTI Líquido - Lote L-003',
  'p4': 'BTI Granulado - Lote L-004',
  'p5': 'BTI Líquido - Lote L-005',
};

/// Produtos disponíveis para seleção no formulário de nova distribuição.
final List<ProdutoReferenciaDistribuicao> mockProdutosReferenciaDistribuicao =
    mockNomesProdutosDistribuicao.entries
        .map(
          (entry) => ProdutoReferenciaDistribuicao(
            id: entry.key,
            nomeExibicao: entry.value,
          ),
        )
        .toList();
