/// Situação de um registro para o aplicador (GEOPRAG-204). São só três: o
/// aplicador não vê conflito, então um registro que o servidor aceitou aparece
/// como [enviado], mesmo que o servidor o tenha marcado como conflito
/// (_Sincronização e Conflitos_, regra 4).
enum SituacaoDoRegistro {
  /// Guardado no aparelho, esperando para ser enviado (inclui o que está sendo
  /// enviado agora e o que falhou por falta de rede).
  pendente,

  /// O servidor recebeu o registro.
  enviado,

  /// O servidor recusou o registro. É só de consulta: sem ação e sem reenvio.
  rejeitado,
}

/// Um registro feito no aparelho, como a lista de sincronização o mostra.
class RegistroSincronizavel {
  const RegistroSincronizavel({
    required this.id,
    required this.pontoId,
    required this.registradoEm,
    required this.situacao,
    this.pontoNome,
    this.motivo,
  });

  final String id;
  final String pontoId;

  /// Nome do ponto, ou `null` se o ponto já saiu do aparelho.
  final String? pontoNome;

  /// Quando o registro foi feito neste aparelho.
  final DateTime registradoEm;
  final SituacaoDoRegistro situacao;

  /// Por que o servidor recusou o registro, em texto legível. Só existe quando
  /// [situacao] é [SituacaoDoRegistro.rejeitado].
  final String? motivo;
}

/// O que a lista de sincronização mostra: os registros do aparelho e quando a
/// última sincronização bem-sucedida aconteceu.
class SituacaoDaSincronizacao {
  const SituacaoDaSincronizacao({
    required this.registros,
    this.ultimaSincronizacao,
  });

  /// Do mais recente para o mais antigo.
  final List<RegistroSincronizavel> registros;

  /// `null` enquanto o aparelho nunca sincronizou com sucesso.
  final DateTime? ultimaSincronizacao;

  /// Quantos registros ainda não foram enviados ao servidor.
  int get pendentes =>
      registros.where((r) => r.situacao == SituacaoDoRegistro.pendente).length;
}

/// Texto do motivo de uma rejeição para o aplicador: sem código nem termo
/// técnico. Um motivo que é só um código (`DADOS_INVALIDOS`) vira o texto
/// genérico.
String motivoLegivelDaRejeicao(String? bruto) {
  const generico = 'Registro recusado pelo servidor.';
  final texto = bruto?.trim() ?? '';
  if (texto.isEmpty || RegExp(r'^[A-Za-z0-9_]+$').hasMatch(texto)) {
    return generico;
  }
  return texto.replaceAll(' para o tenant', '');
}
