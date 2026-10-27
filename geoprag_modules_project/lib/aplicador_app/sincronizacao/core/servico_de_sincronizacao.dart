import 'resultado_da_sincronizacao.dart';

/// Serviço que leva os registros do aparelho ao servidor e traz de volta os
/// pontos atribuídos ao aplicador (GEOPRAG-190 e 202).
///
/// Todas as operações rodam num **único fluxo por vez**: duas chamadas
/// simultâneas não geram dois envios nem dois pulls. A segunda espera o fluxo
/// em curso e, se chegou item novo ou pedido novo enquanto ele rodava, ele faz
/// mais uma rodada.
abstract interface class ServicoDeSincronizacao {
  /// Envia ao servidor os itens `PENDENTE` da outbox, em lotes, e marca cada
  /// item conforme a resposta (`ENVIADO` ou `REJEITADO`).
  ///
  /// **Nunca perde registro.** Falha de rede, tempo esgotado, erro do servidor
  /// ou sessão sem renovação deixam os itens `PENDENTE`, à espera da próxima
  /// tentativa.
  Future<void> enviarPendentes();

  /// Sincronização completa: envia a outbox e, **depois**, baixa os pontos do
  /// aplicador (`GET /sync/pull`) e os reconcilia com o banco local. É o que
  /// rodam os gatilhos (abrir o app, voltar ao primeiro plano, recuperar a
  /// conexão) e a ação manual "Sincronizar agora".
  ///
  /// O pull **nunca apaga ponto com registro pendente** na outbox. Não lança por
  /// falha de rede ou do servidor: devolve um [ResultadoDaSincronizacao] com
  /// `concluida == false`, e o banco fica como estava.
  Future<ResultadoDaSincronizacao> sincronizar();
}
