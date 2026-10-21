/// Espera entre tentativas de sincronização que falharam (GEOPRAG-202): dobra a
/// cada falha, de [inicial] até [maxima], e volta ao começo quando uma
/// sincronização dá certo.
class EsperaCrescente {
  EsperaCrescente({
    this.inicial = const Duration(seconds: 5),
    this.maxima = const Duration(minutes: 5),
  }) : assert(inicial > Duration.zero && maxima >= inicial);

  final Duration inicial;
  final Duration maxima;

  int _falhas = 0;

  /// A espera até a próxima tentativa; cada chamada conta uma falha.
  Duration proxima() {
    // Limita o expoente: depois de poucas dobras já se está na [maxima].
    final fator = 1 << (_falhas < 20 ? _falhas : 20);
    _falhas++;
    final espera = inicial * fator;
    return espera > maxima ? maxima : espera;
  }

  /// A sincronização deu certo: a próxima falha volta a esperar [inicial].
  void reiniciar() => _falhas = 0;
}
