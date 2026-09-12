/// Um registro de saída/distribuição de produto para um responsável em
/// campo, exibido na listagem e na ficha de distribuição do Portal
/// Administrador.
class Distribuicao {
  final String id;
  final String produtoId;
  final int quantidade;
  final String unidade; // 'Litros' | 'Kg'
  final DateTime dataEntrega;
  final String responsavel;
  final String bairroResponsavel;
  final String
  statusConfirmacao; // 'aguardando_aceite' | 'confirmado' | 'recusado'

  const Distribuicao({
    required this.id,
    required this.produtoId,
    required this.quantidade,
    required this.unidade,
    required this.dataEntrega,
    required this.responsavel,
    required this.bairroResponsavel,
    required this.statusConfirmacao,
  });
}
