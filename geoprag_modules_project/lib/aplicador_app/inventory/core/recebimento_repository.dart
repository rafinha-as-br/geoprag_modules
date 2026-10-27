import 'recebimento.dart';

/// Contrato de acesso aos dados de Recebimentos (entregas de insumos) do
/// aplicador.
///
/// TODO(GEOPRAG-24): contrato real dos endpoints ainda não validado com o
/// backend.
abstract class RecebimentoRepository {
  Future<List<Recebimento>> listarPendentes();
  Future<Recebimento> buscarPorId(String id);

  /// Confirma o recebimento e devolve o estado atualizado. [confirmadoEm] é
  /// o instante da ocorrência (padrão: agora). Sem conexão, a confirmação
  /// fica pendente de sincronização ([Recebimento.pendenteSincronizacao]).
  Future<Recebimento> confirmar(String id, {DateTime? confirmadoEm});

  /// Registra no servidor as confirmações feitas offline. Devolve as
  /// confirmações sincronizadas (vazio se não houver nada a sincronizar ou
  /// se ainda não houver conexão).
  Future<List<Recebimento>> sincronizarPendentes();
}
