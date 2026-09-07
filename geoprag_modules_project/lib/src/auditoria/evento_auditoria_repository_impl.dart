import 'evento_auditoria.dart';
import 'evento_auditoria_repository.dart';

/// Acumula em memória, mesmo padrão de `mockPontosDeAplicacao`/
/// `mockAdminAccounts`: uma lista global viva entre instâncias — cada
/// `EventoAuditoriaRepositoryImpl()` é uma fábrica barata sobre a mesma
/// lista, não um store isolado por instância. Pública para poder ser
/// limpa em `tearDown` de teste, como as demais.
final List<EventoAuditoria> mockEventosAuditoria = [];

class EventoAuditoriaRepositoryImpl implements EventoAuditoriaRepository {
  @override
  Future<void> registrar(EventoAuditoria evento) async {
    mockEventosAuditoria.add(evento);
  }

  @override
  Future<List<EventoAuditoria>> listarTodos() async {
    return mockEventosAuditoria.toList();
  }
}
