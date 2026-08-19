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
}
