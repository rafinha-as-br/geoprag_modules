/// Validador genérico de campo obrigatório, reaproveitado pelos
/// `BaseFormController`s do pacote em vez de cada um reimplementar a mesma
/// checagem de string vazia (GEOPRAG-105).
String? validarObrigatorio(String? value, String mensagem) =>
    (value == null || value.isEmpty) ? mensagem : null;

/// Converte o texto de um campo decimal, aceitando `,` como separador —
/// `null` quando o texto ainda não é um número.
///
/// É a mesma leitura que [validarNumeroPositivo] faz: um `BaseFormController`
/// que valida com um e converte com o outro garante que o valor aprovado na
/// validação é exatamente o que ele vai persistir.
double? decimalDoFormulario(String? value) =>
    double.tryParse((value ?? '').replaceAll(',', '.'));

/// Validador genérico de número positivo (aceita `,` como separador
/// decimal), reaproveitado pelos `BaseFormController`s do pacote.
String? validarNumeroPositivo(
  String? value, [
  String mensagem = 'Informe um valor válido.',
]) {
  final numero = decimalDoFormulario(value);
  return (numero == null || numero <= 0) ? mensagem : null;
}
