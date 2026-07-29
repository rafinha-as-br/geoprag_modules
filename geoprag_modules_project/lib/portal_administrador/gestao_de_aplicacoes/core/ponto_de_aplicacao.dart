import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_colors.dart';

/// Estado de execução de um ponto de aplicação química — diferente de
/// [GeopragStatus] (que descreve pontualidade do aplicador): aqui o que
/// importa é se a aplicação já ocorreu, está agendada ou passou do prazo.
enum StatusPontoDeAplicacao { feita, planejada, atrasada }

extension StatusPontoDeAplicacaoStyle on StatusPontoDeAplicacao {
  Color get color {
    switch (this) {
      case StatusPontoDeAplicacao.feita:
        return GeopragColors.statusEmDia;
      case StatusPontoDeAplicacao.planejada:
        return GeopragColors.blue600;
      case StatusPontoDeAplicacao.atrasada:
        return GeopragColors.statusAtrasado;
    }
  }

  Color get background => color.withValues(alpha: 0.12);

  String get defaultLabel {
    switch (this) {
      case StatusPontoDeAplicacao.feita:
        return 'Feita';
      case StatusPontoDeAplicacao.planejada:
        return 'Planejada';
      case StatusPontoDeAplicacao.atrasada:
        return 'Atrasada';
    }
  }
}

/// Um ponto de aplicação química cadastrado em um bairro de Gaspar.
///
/// [ativo] é uma desativação lógica — um ponto nunca é deletado, apenas
/// marcado como inativo. [aplicadorId] é nullable: um ponto pode existir
/// sem aplicador atribuído (ex.: recém-criado).
class AdminPontoDeAplicacao {
  final String id;
  final String bairro;
  final double lat;
  final double lng;
  final StatusPontoDeAplicacao status;
  final bool ativo;
  final String? aplicadorId;
  final DateTime? dataAgendada;
  final DateTime? dataConcluida;

  const AdminPontoDeAplicacao({
    required this.id,
    required this.bairro,
    required this.lat,
    required this.lng,
    required this.status,
    this.ativo = true,
    this.aplicadorId,
    this.dataAgendada,
    this.dataConcluida,
  });

  AdminPontoDeAplicacao copyWith({
    StatusPontoDeAplicacao? status,
    bool? ativo,
    String? Function()? aplicadorId,
    DateTime? Function()? dataAgendada,
    DateTime? Function()? dataConcluida,
  }) {
    return AdminPontoDeAplicacao(
      id: id,
      bairro: bairro,
      lat: lat,
      lng: lng,
      status: status ?? this.status,
      ativo: ativo ?? this.ativo,
      aplicadorId: aplicadorId != null ? aplicadorId() : this.aplicadorId,
      dataAgendada: dataAgendada != null ? dataAgendada() : this.dataAgendada,
      dataConcluida: dataConcluida != null
          ? dataConcluida()
          : this.dataConcluida,
    );
  }
}
