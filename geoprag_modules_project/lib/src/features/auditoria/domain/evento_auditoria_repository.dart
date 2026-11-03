import 'evento_auditoria.dart';

/// Contrato de domínio da trilha de auditoria (GEOPRAG-113) — hoje um mock
/// em memória ([EventoAuditoriaRepositoryImpl]), pronto para uma tabela
/// dedicada quando a API existir (ver GEOPRAG-114). Deliberadamente sem
/// nenhuma operação de edição ou remoção: a trilha é append-only.
abstract class EventoAuditoriaRepository {
  Future<void> registrar(EventoAuditoria evento);
  Future<List<EventoAuditoria>> listarTodos();
}
