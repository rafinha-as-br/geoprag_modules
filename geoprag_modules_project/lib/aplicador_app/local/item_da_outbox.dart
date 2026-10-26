import 'dart:convert';

import '../../src/api/sync/registro_dtos.dart';

/// Situação de um item da outbox (fila de envio ao servidor).
enum EstadoDoItemDaOutbox {
  /// Esperando envio (inclui o item que falhou por rede e volta à fila).
  pendente('PENDENTE'),

  /// Enviado agora; a resposta do servidor ainda não foi processada.
  enviando('ENVIANDO'),

  /// O servidor aceitou (`CRIADO` ou `DUPLICADO`).
  enviado('ENVIADO'),

  /// O servidor recusou por dado inválido ou inexistente; não é reenviado
  /// sozinho.
  rejeitado('REJEITADO');

  const EstadoDoItemDaOutbox(this.valor);

  /// Valor guardado no banco.
  final String valor;

  static EstadoDoItemDaOutbox doValor(String valor) {
    for (final estado in values) {
      if (estado.valor == valor) return estado;
    }
    throw FormatException('Estado de outbox desconhecido: "$valor".');
  }
}

/// O que o item da outbox carrega.
enum TipoDoItemDaOutbox {
  /// Um subponto de uma aplicação (`ItemDeRegistroDto` de
  /// `POST /sync/aplicacoes`).
  subponto('SUBPONTO');

  const TipoDoItemDaOutbox(this.valor);

  /// Valor guardado no banco.
  final String valor;

  static TipoDoItemDaOutbox doValor(String valor) {
    for (final tipo in values) {
      if (tipo.valor == valor) return tipo;
    }
    throw FormatException('Tipo de outbox desconhecido: "$valor".');
  }
}

/// Um item da fila de envio (outbox).
///
/// O [id] é o UUID do registro (o `id` do subponto): é ele que torna o reenvio
/// idempotente no servidor. O [payload] é o JSON exato que vai no lote, gravado
/// no momento do registro — o envio nunca recalcula nada a partir de outros
/// dados que possam ter mudado.
class ItemDaOutbox {
  const ItemDaOutbox({
    required this.id,
    required this.tipo,
    required this.pontoId,
    required this.payload,
    required this.estado,
    required this.tentativas,
    required this.criadoEm,
    this.ultimoErro,
    this.ultimaTentativaEm,
  });

  /// Item novo, `PENDENTE` e sem tentativas.
  factory ItemDaOutbox.novo({
    required String id,
    required TipoDoItemDaOutbox tipo,
    required String pontoId,
    required String payload,
    required DateTime criadoEm,
  }) => ItemDaOutbox(
    id: id,
    tipo: tipo,
    pontoId: pontoId,
    payload: payload,
    estado: EstadoDoItemDaOutbox.pendente,
    tentativas: 0,
    criadoEm: criadoEm,
  );

  /// Item `PENDENTE` de um subponto: o `id` é o do subponto e o [payload] é o
  /// [ItemDeRegistroDto] serializado.
  factory ItemDaOutbox.paraSubponto(
    ItemDeRegistroDto registro, {
    required DateTime criadoEm,
  }) => ItemDaOutbox.novo(
    id: registro.id,
    tipo: TipoDoItemDaOutbox.subponto,
    pontoId: registro.pontoId,
    payload: jsonEncode(registro.toJson()),
    criadoEm: criadoEm,
  );

  /// UUID do registro (o `id` do subponto).
  final String id;
  final TipoDoItemDaOutbox tipo;

  /// Ponto a que o registro pertence. Existe separado do [payload] para a regra
  /// "o pull nunca apaga ponto com registro pendente" não precisar abrir JSON.
  final String pontoId;

  /// JSON do que vai ao servidor.
  final String payload;
  final EstadoDoItemDaOutbox estado;

  /// Quantas vezes o item foi marcado como `ENVIANDO`.
  final int tentativas;

  /// Motivo da última falha de rede ou da rejeição (texto para exibição).
  final String? ultimoErro;
  final DateTime criadoEm;

  /// Quando o item foi marcado como `ENVIANDO` pela última vez; base da espera
  /// crescente entre tentativas.
  final DateTime? ultimaTentativaEm;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemDaOutbox &&
          other.id == id &&
          other.tipo == tipo &&
          other.pontoId == pontoId &&
          other.payload == payload &&
          other.estado == estado &&
          other.tentativas == tentativas &&
          other.ultimoErro == ultimoErro &&
          other.criadoEm.isAtSameMomentAs(criadoEm) &&
          _mesmoInstante(other.ultimaTentativaEm, ultimaTentativaEm));

  @override
  int get hashCode => Object.hash(
    id,
    tipo,
    pontoId,
    payload,
    estado,
    tentativas,
    ultimoErro,
    criadoEm.microsecondsSinceEpoch,
    ultimaTentativaEm?.microsecondsSinceEpoch,
  );

  /// Nunca expõe o payload (coordenadas do aplicador) em logs.
  @override
  String toString() => 'ItemDaOutbox(id: $id, estado: ${estado.valor})';

  static bool _mesmoInstante(DateTime? a, DateTime? b) =>
      a == null || b == null ? a == b : a.isAtSameMomentAs(b);
}
