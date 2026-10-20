/// Leitura defensiva de JSON para os DTOs: um campo ausente ou do tipo errado
/// vira [FormatException] com o nome do campo, nunca um `TypeError` solto.
///
/// Mensagens de [FormatException] são técnicas (para log); quem chama a API
/// deve traduzi-las numa mensagem amigável.
String textoObrigatorio(Map<String, dynamic> json, String campo) {
  final valor = json[campo];
  if (valor is String && valor.isNotEmpty) return valor;
  throw FormatException('Campo "$campo" ausente ou inválido na resposta.');
}

String? textoOpcional(Map<String, dynamic> json, String campo) {
  final valor = json[campo];
  if (valor == null) return null;
  if (valor is String) return valor;
  throw FormatException('Campo "$campo" inválido na resposta.');
}

int inteiroObrigatorio(Map<String, dynamic> json, String campo) {
  final valor = json[campo];
  if (valor is int) return valor;
  if (valor is num && valor == valor.truncate()) return valor.toInt();
  throw FormatException('Campo "$campo" ausente ou inválido na resposta.');
}

Map<String, dynamic> objetoObrigatorio(
  Map<String, dynamic> json,
  String campo,
) {
  final valor = json[campo];
  if (valor is Map<String, dynamic>) return valor;
  throw FormatException('Campo "$campo" ausente ou inválido na resposta.');
}
