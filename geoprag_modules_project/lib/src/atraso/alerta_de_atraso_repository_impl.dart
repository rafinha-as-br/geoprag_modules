import 'alerta_de_atraso_repository.dart';

/// Remoções por ponto, em memória, mesmo padrão de `mockEventosAuditoria`:
/// um mapa global vivo entre instâncias — cada `AlertaDeAtrasoRepositoryImpl()`
/// é uma fábrica barata sobre o mesmo mapa, e é isso que faz o App enxergar a
/// remoção feita no Portal. Pública para poder ser limpa em `tearDown`.
final Map<String, Set<String>> mockAlertasDeAtrasoRemovidos = {};

class AlertaDeAtrasoRepositoryImpl implements AlertaDeAtrasoRepository {
  @override
  Future<Set<String>> listarRemovidos(String pontoId) async =>
      Set.of(mockAlertasDeAtrasoRemovidos[pontoId] ?? const {});

  @override
  Future<void> remover({
    required String pontoId,
    required String dataAgendadaId,
  }) async {
    mockAlertasDeAtrasoRemovidos
        .putIfAbsent(pontoId, () => {})
        .add(dataAgendadaId);
  }
}
