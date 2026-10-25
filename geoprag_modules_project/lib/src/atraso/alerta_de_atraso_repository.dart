/// Contrato da remoção manual do alerta de atraso (GEOPRAG-160), compartilhado
/// pelo Portal Administrador (que remove) e pelo App Aplicador (que reflete a
/// remoção depois de sincronizar, GEOPRAG-161).
///
/// A remoção é de uma recorrência, não do ponto: guarda-se o id da
/// [DataAgendada] cujo alerta foi removido, então o alerta da próxima
/// recorrência que atrasar volta a aparecer.
///
/// Hoje uma implementação local ([AlertaDeAtrasoRepositoryImpl]); a troca por
/// HTTP entra com a API, sem refazer as telas.
abstract class AlertaDeAtrasoRepository {
  /// Ids das [DataAgendada] do ponto [pontoId] cujo alerta foi removido.
  Future<Set<String>> listarRemovidos(String pontoId);

  /// Registra a remoção do alerta da recorrência [dataAgendadaId] do ponto
  /// [pontoId]. Idempotente.
  Future<void> remover({
    required String pontoId,
    required String dataAgendadaId,
  });
}
