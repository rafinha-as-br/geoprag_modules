/// Referência mínima de um responsável de campo disponível para seleção no
/// formulário de nova distribuição (dropdown "Responsável pelo
/// Recebimento").
///
/// TODO(GEOPRAG-24): hoje replicado localmente em mock; substituir por uma
/// consulta real assim que houver integração com o cadastro de aplicadores
/// (`gestao_de_aplicadores`) ou com o backend.
class ResponsavelReferenciaDistribuicao {
  final String id;
  final String nome;
  final String bairro;

  const ResponsavelReferenciaDistribuicao({
    required this.id,
    required this.nome,
    required this.bairro,
  });
}
