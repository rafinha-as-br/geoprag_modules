/// Referência mínima de um produto disponível para seleção no formulário de
/// nova distribuição (dropdown "Produto/Lote").
///
/// Dados completos do produto (validade, quantidade em estoque etc.)
/// pertencem ao módulo `inventory_and_bidding`, hoje em reconstrução em
/// paralelo — este módulo não deve depender do seu Cubit/Repository, então
/// mantém apenas os campos necessários para o dropdown, replicados
/// localmente em mock.
///
/// TODO(GEOPRAG-24): substituir por uma consulta real ao módulo de estoque
/// (ou ao backend) assim que a agregação entre os dois módulos existir.
class ProdutoReferenciaDistribuicao {
  final String id;
  final String nomeExibicao; // ex.: 'BTI Líquido - Lote L-001'

  const ProdutoReferenciaDistribuicao({
    required this.id,
    required this.nomeExibicao,
  });
}
