/// Validador genérico de campo obrigatório, reaproveitado pelos
/// `BaseFormController`s do pacote em vez de cada um reimplementar a mesma
/// checagem de string vazia (GEOPRAG-105).
String? validarObrigatorio(String? value, String mensagem) =>
    (value == null || value.isEmpty) ? mensagem : null;

/// Validador genérico de número positivo (aceita `,` como separador
/// decimal), reaproveitado pelos `BaseFormController`s do pacote.
String? validarNumeroPositivo(
  String? value, [
  String mensagem = 'Informe um valor válido.',
]) {
  final numero = double.tryParse((value ?? '').replaceAll(',', '.'));
  return (numero == null || numero <= 0) ? mensagem : null;
}
