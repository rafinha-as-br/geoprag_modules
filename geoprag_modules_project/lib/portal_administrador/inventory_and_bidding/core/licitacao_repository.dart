import 'licitacao.dart';

/// Contrato de acesso aos dados de Licitações/Editais do Portal
/// Administrador.
///
/// TODO(GEOPRAG-24): contrato real dos endpoints ainda não validado com o
/// backend.
abstract class LicitacaoRepository {
  Future<List<Licitacao>> listar();

  Future<Licitacao> criar({
    required String numeroAno,
    required String fornecedorVencedor,
    required String objetoLicitado,
    required double valorTotal,
    required DateTime dataHomologacao,
  });
}
