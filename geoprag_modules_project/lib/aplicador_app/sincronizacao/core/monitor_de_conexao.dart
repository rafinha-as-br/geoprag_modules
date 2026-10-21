/// Aviso de rede do aparelho. Interface para os gatilhos de envio serem
/// testáveis sem plugin nativo.
///
/// Existir rede **não** quer dizer que o servidor responde: quem decide se o
/// envio deu certo é a resposta dele, nunca este monitor.
abstract interface class MonitorDeConexao {
  /// Emite sempre que o aparelho passa a ter alguma interface de rede (Wi-Fi,
  /// dados móveis…), inclusive na troca de uma rede por outra.
  Stream<void> get aoConectar;
}
