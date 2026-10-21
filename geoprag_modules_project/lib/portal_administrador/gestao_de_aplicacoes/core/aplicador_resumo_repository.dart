import 'aplicador_resumo.dart';

/// Aplicadores do município para a Gestão de Aplicações: mostrar quem é o
/// responsável de um ponto e escolher quem recebe um ponto.
abstract interface class AplicadorResumoRepository {
  /// Todos os aplicadores, ativos e desativados, em ordem alfabética (um ponto
  /// pode seguir apontando para um aplicador que já foi desativado).
  Future<List<AplicadorResumo>> listar();
}
