import 'sync_json.dart';

/// Um subponto no lote de `POST /sync/aplicacoes` (contrato v0, "API -
/// Registro de Aplicação"). Cada item é um subponto; `aplicacaoId` agrupa os
/// da mesma aplicação.
class ItemDeRegistroDto {
  const ItemDeRegistroDto({
    required this.id,
    required this.aplicacaoId,
    required this.pontoId,
    required this.dataAgendadaId,
    required this.produtoId,
    required this.latitude,
    required this.longitude,
    required this.realizadoEm,
  });

  /// UUID v4 do subponto, gerado no aparelho.
  final String id;

  /// UUID v4 da aplicação, gerado no aparelho.
  final String aplicacaoId;
  final String pontoId;
  final String dataAgendadaId;
  final String produtoId;
  final double latitude;
  final double longitude;

  /// Relógio do aparelho. Vai ao servidor com o offset do próprio valor.
  final DateTime realizadoEm;

  factory ItemDeRegistroDto.fromJson(Map<String, dynamic> json) =>
      ItemDeRegistroDto(
        id: textoObrigatorio(json, 'id'),
        aplicacaoId: textoObrigatorio(json, 'aplicacaoId'),
        pontoId: textoObrigatorio(json, 'pontoId'),
        dataAgendadaId: textoObrigatorio(json, 'dataAgendadaId'),
        produtoId: textoObrigatorio(json, 'produtoId'),
        latitude: numeroObrigatorio(json, 'latitude'),
        longitude: numeroObrigatorio(json, 'longitude'),
        realizadoEm: dataHoraObrigatoria(json, 'realizadoEm'),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'aplicacaoId': aplicacaoId,
    'pontoId': pontoId,
    'dataAgendadaId': dataAgendadaId,
    'produtoId': produtoId,
    'latitude': latitude,
    'longitude': longitude,
    'realizadoEm': formatarDataHoraComOffset(realizadoEm),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemDeRegistroDto &&
          other.id == id &&
          other.aplicacaoId == aplicacaoId &&
          other.pontoId == pontoId &&
          other.dataAgendadaId == dataAgendadaId &&
          other.produtoId == produtoId &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.realizadoEm.isAtSameMomentAs(realizadoEm));

  @override
  int get hashCode => Object.hash(
    id,
    aplicacaoId,
    pontoId,
    dataAgendadaId,
    produtoId,
    latitude,
    longitude,
    realizadoEm.microsecondsSinceEpoch,
  );

  @override
  String toString() => 'ItemDeRegistroDto(id: $id)';
}

/// Corpo de `POST /sync/aplicacoes`.
class LoteDeRegistroDto {
  const LoteDeRegistroDto({required this.dispositivoId, required this.itens});

  final String dispositivoId;
  final List<ItemDeRegistroDto> itens;

  Map<String, dynamic> toJson() => {
    'dispositivoId': dispositivoId,
    'itens': [for (final item in itens) item.toJson()],
  };

  @override
  String toString() =>
      'LoteDeRegistroDto(itens: ${itens.length}, dispositivo: $dispositivoId)';
}

/// Resultado de um item do lote.
enum StatusItemDto {
  /// Gravado agora.
  criado('CRIADO'),

  /// Já estava gravado (reenvio): também é sucesso para o app.
  duplicado('DUPLICADO'),

  /// Recusado por dado inválido ou inexistente; não é reenviado sozinho.
  rejeitado('REJEITADO');

  const StatusItemDto(this.valorJson);

  final String valorJson;

  /// `CRIADO` e `DUPLICADO` tiram o item da outbox.
  bool get entregue => this != rejeitado;

  static StatusItemDto fromJson(String valor) {
    for (final status in values) {
      if (status.valorJson == valor) return status;
    }
    throw FormatException('Status de item desconhecido: "$valor".');
  }
}

/// Item de `resultados[]` da resposta do lote (não usa o formato RFC 7807).
class ResultadoDoItemDto {
  const ResultadoDoItemDto({
    required this.id,
    required this.status,
    this.codigo,
    this.motivo,
  });

  /// Mesmo `id` do item enviado.
  final String id;
  final StatusItemDto status;

  /// Só em `REJEITADO`: `DADOS_INVALIDOS`, `PONTO_INEXISTENTE` ou
  /// `PRODUTO_INEXISTENTE` (mantido como texto: o contrato os marca como
  /// propostos).
  final String? codigo;

  /// Só em `REJEITADO`: texto em pt-BR para exibição.
  final String? motivo;

  factory ResultadoDoItemDto.fromJson(Map<String, dynamic> json) =>
      ResultadoDoItemDto(
        id: textoObrigatorio(json, 'id'),
        status: StatusItemDto.fromJson(textoObrigatorio(json, 'status')),
        codigo: textoOpcional(json, 'codigo'),
        motivo: textoOpcional(json, 'motivo'),
      );
}

/// Resposta de `POST /sync/aplicacoes`: um resultado por item, na mesma ordem
/// do envio.
class RespostaDoLoteDto {
  const RespostaDoLoteDto({required this.recebidoEm, required this.resultados});

  /// Relógio do servidor.
  final DateTime recebidoEm;
  final List<ResultadoDoItemDto> resultados;

  factory RespostaDoLoteDto.fromJson(Map<String, dynamic> json) =>
      RespostaDoLoteDto(
        recebidoEm: dataHoraObrigatoria(json, 'recebidoEm'),
        resultados: [
          for (final item in listaDeObjetos(json, 'resultados'))
            ResultadoDoItemDto.fromJson(item),
        ],
      );
}
