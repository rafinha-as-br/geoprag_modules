/// Leitura e escrita defensivas de JSON para os DTOs de sincronização: campo
/// ausente ou do tipo errado vira [FormatException] com o nome do campo, nunca
/// um `TypeError` solto. As mensagens são técnicas (para log); quem chama a
/// API as traduz numa mensagem amigável.
library;

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

int? inteiroOpcional(Map<String, dynamic> json, String campo) {
  if (json[campo] == null) return null;
  return inteiroObrigatorio(json, campo);
}

double numeroObrigatorio(Map<String, dynamic> json, String campo) {
  final valor = json[campo];
  if (valor is num) return valor.toDouble();
  throw FormatException('Campo "$campo" ausente ou inválido na resposta.');
}

double? numeroOpcional(Map<String, dynamic> json, String campo) {
  if (json[campo] == null) return null;
  return numeroObrigatorio(json, campo);
}

Map<String, dynamic> objetoObrigatorio(
  Map<String, dynamic> json,
  String campo,
) {
  final valor = json[campo];
  if (valor is Map<String, dynamic>) return valor;
  throw FormatException('Campo "$campo" ausente ou inválido na resposta.');
}

Map<String, dynamic>? objetoOpcional(Map<String, dynamic> json, String campo) {
  if (json[campo] == null) return null;
  return objetoObrigatorio(json, campo);
}

/// Lista de objetos JSON; ausente vale lista vazia só quando [opcional].
List<Map<String, dynamic>> listaDeObjetos(
  Map<String, dynamic> json,
  String campo, {
  bool opcional = false,
}) {
  final valor = json[campo];
  if (valor == null && opcional) return const [];
  if (valor is List && valor.every((e) => e is Map<String, dynamic>)) {
    return valor.cast<Map<String, dynamic>>();
  }
  throw FormatException('Campo "$campo" ausente ou inválido na resposta.');
}

/// Lista de textos; ausente vale lista vazia só quando [opcional].
List<String> listaDeTextos(
  Map<String, dynamic> json,
  String campo, {
  bool opcional = false,
}) {
  final valor = json[campo];
  if (valor == null && opcional) return const [];
  if (valor is List && valor.every((e) => e is String)) {
    return valor.cast<String>();
  }
  throw FormatException('Campo "$campo" ausente ou inválido na resposta.');
}

final RegExp _comOffset = RegExp(r'(Z|[+-]\d{2}:\d{2})$');

/// Data e hora ISO-8601 **com offset** (exigido pelo contrato); sem offset é
/// erro, porque o instante seria ambíguo.
DateTime dataHoraObrigatoria(Map<String, dynamic> json, String campo) {
  final texto = textoObrigatorio(json, campo);
  if (!_comOffset.hasMatch(texto)) {
    throw FormatException('Campo "$campo" sem offset de fuso na resposta.');
  }
  final valor = DateTime.tryParse(texto);
  if (valor == null) {
    throw FormatException('Campo "$campo" com data e hora inválidas.');
  }
  return valor;
}

DateTime? dataHoraOpcional(Map<String, dynamic> json, String campo) {
  if (json[campo] == null) return null;
  return dataHoraObrigatoria(json, campo);
}

/// Data de calendário `yyyy-MM-dd` (datas agendadas), como [DateTime] local à
/// meia-noite.
DateTime dataDeCalendario(Map<String, dynamic> json, String campo) {
  final texto = textoObrigatorio(json, campo);
  final partes = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(texto);
  if (partes == null) {
    throw FormatException('Campo "$campo" não é uma data yyyy-MM-dd.');
  }
  final data = DateTime(
    int.parse(partes.group(1)!),
    int.parse(partes.group(2)!),
    int.parse(partes.group(3)!),
  );
  if (data.month != int.parse(partes.group(2)!) ||
      data.day != int.parse(partes.group(3)!)) {
    throw FormatException('Campo "$campo" com data inexistente.');
  }
  return data;
}

String formatarDataDeCalendario(DateTime data) =>
    '${data.year.toString().padLeft(4, '0')}-'
    '${data.month.toString().padLeft(2, '0')}-'
    '${data.day.toString().padLeft(2, '0')}';

/// ISO-8601 **com offset** do próprio [instante] (o do aparelho, quando local;
/// `+00:00` quando UTC). Ex.: `2026-10-21T14:30:00-03:00`.
String formatarDataHoraComOffset(DateTime instante) {
  String dois(int n) => n.toString().padLeft(2, '0');
  final offset = instante.timeZoneOffset;
  final sinal = offset.isNegative ? '-' : '+';
  final horas = dois(offset.inHours.abs());
  final minutos = dois(offset.inMinutes.abs() % 60);
  final fracao = instante.millisecond == 0 && instante.microsecond == 0
      ? ''
      : '.${instante.millisecond.toString().padLeft(3, '0')}';
  return '${instante.year.toString().padLeft(4, '0')}-${dois(instante.month)}-'
      '${dois(instante.day)}T${dois(instante.hour)}:${dois(instante.minute)}:'
      '${dois(instante.second)}$fracao$sinal$horas:$minutos';
}
