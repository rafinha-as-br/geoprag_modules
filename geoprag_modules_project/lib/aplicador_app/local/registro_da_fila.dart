import 'item_da_outbox.dart';

/// Um item da outbox junto com o nome do ponto a que pertence, para a lista
/// de registros do aparelho (GEOPRAG-204).
///
/// [pontoNome] é `null` quando o ponto não está mais no aparelho (o servidor o
/// retirou do aplicador): o registro continua na lista.
class RegistroDaFila {
  const RegistroDaFila({required this.item, this.pontoNome});

  final ItemDaOutbox item;
  final String? pontoNome;
}

/// Consulta dos registros do aparelho para a lista de sincronização do
/// aplicador. Separada do `OutboxDao` (que o serviço de envio usa) para que
/// quem só envia não dependa de uma consulta de tela.
abstract interface class RegistrosDaFilaDao {
  /// Do mais recente para o mais antigo: todos os registros que não foram
  /// enviados (`PENDENTE`, `ENVIANDO` e `REJEITADO`) e os [enviadosRecentes]
  /// últimos `ENVIADO`.
  Future<List<RegistroDaFila>> registrosParaExibir({
    int enviadosRecentes = 100,
  });
}
