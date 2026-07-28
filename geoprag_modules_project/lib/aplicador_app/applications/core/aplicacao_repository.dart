import '../../../src/entities/aplicacao.dart';

/// Contrato de acesso aos dados de Aplicações (registro de uso do produto
/// biológico) do `aplicador_app`.
///
/// Este app opera com um aplicador de cada vez — não há listagem navegável
/// de aplicações, apenas a aplicação atual/em andamento do aplicador
/// autenticado.
///
/// TODO(GEOPRAG-24): contrato real dos endpoints ainda não validado com o
/// backend.
abstract class AplicacaoRepository {
  Future<Aplicacao> buscarAtual(String aplicadorId);
}
