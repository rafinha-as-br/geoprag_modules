/// Serviço que leva os registros do aparelho ao servidor (GEOPRAG-190).
///
/// Hoje só o envio da outbox; o pull dos pontos e a reconciliação com o banco
/// local entram com a GEOPRAG-202, no mesmo serviço.
abstract interface class ServicoDeSincronizacao {
  /// Envia ao servidor os itens `PENDENTE` da outbox, em lotes, e marca cada
  /// item conforme a resposta (`ENVIADO` ou `REJEITADO`).
  ///
  /// **Nunca perde registro.** Falha de rede, tempo esgotado, erro do servidor
  /// ou sessão sem renovação deixam os itens `PENDENTE`, à espera da próxima
  /// tentativa. Duas chamadas simultâneas não geram dois envios: a segunda
  /// espera o fluxo em curso e, se chegou item novo enquanto ele rodava, ele
  /// faz mais uma rodada.
  Future<void> enviarPendentes();
}
