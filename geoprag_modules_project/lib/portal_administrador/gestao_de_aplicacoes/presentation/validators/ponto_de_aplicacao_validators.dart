/// Validadores de formulário compartilhados entre a criação e a edição de um
/// ponto de aplicação (`CriacaoDePontoScreen` e a edição na tela de detalhe).
class PontoDeAplicacaoValidators {
  const PontoDeAplicacaoValidators._();

  static String? bairro(String? value) {
    return (value == null || value.isEmpty) ? 'Informe o bairro.' : null;
  }

  static String? coordenada(String? value) {
    if (value == null || value.isEmpty) return 'Informe a coordenada.';
    return double.tryParse(value) == null ? 'Coordenada inválida.' : null;
  }

  /// Distância (em metros) que dispara o alerta de subponto (GEOPRAG-74) —
  /// precisa ser um número positivo.
  static String? distanciaAlertaMetros(String? value) {
    if (value == null || value.isEmpty) return 'Informe a distância.';
    final numero = double.tryParse(value);
    if (numero == null) return 'Distância inválida.';
    return numero <= 0 ? 'Distância deve ser maior que zero.' : null;
  }
}
