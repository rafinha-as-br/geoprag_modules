import 'registro_sincronizavel.dart';

/// O que a interface precisa da sincronização (GEOPRAG-204): a lista de
/// registros com a situação de cada um, o aviso de que algo mudou e a ação
/// "Sincronizar agora". Interface para testar a tela e o cubit sem banco.
abstract interface class PainelDeSincronizacao {
  /// Avisa que uma sincronização terminou e a lista pode ter mudado (inclusive
  /// as automáticas: abrir o app, voltar ao primeiro plano, recuperar a rede).
  Stream<void> get aoMudar;

  Future<SituacaoDaSincronizacao> carregar();

  /// Sincroniza agora, como a ação manual. Devolve `false` se não foi possível
  /// concluir (sem rede, servidor fora): os registros continuam guardados.
  Future<bool> sincronizarAgora();
}
