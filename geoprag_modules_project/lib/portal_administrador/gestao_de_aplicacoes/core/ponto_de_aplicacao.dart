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
///
/// [distanciaAlertaMetros] é a distância (em metros) percorrida pelo
/// aplicador dentro deste ponto que dispara o alerta de subponto — antes
/// da GEOPRAG-74 esse valor era fixo em 150m para todo o sistema; passa a
/// ser configurável por ponto (RN "Georreferenciamento e Validação").
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
  final double distanciaAlertaMetros;

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
    this.distanciaAlertaMetros = 150.0,
  });

  AdminPontoDeAplicacao copyWith({
    String? bairro,
    double? lat,
    double? lng,
    StatusPontoDeAplicacao? status,
    bool? ativo,
    String? Function()? aplicadorId,
    DateTime? Function()? dataAgendada,
    DateTime? Function()? dataConcluida,
    double? distanciaAlertaMetros,
  }) {
    return AdminPontoDeAplicacao(
      id: id,
      bairro: bairro ?? this.bairro,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      status: status ?? this.status,
      ativo: ativo ?? this.ativo,
      aplicadorId: aplicadorId != null ? aplicadorId() : this.aplicadorId,
      dataAgendada: dataAgendada != null ? dataAgendada() : this.dataAgendada,
      dataConcluida: dataConcluida != null
          ? dataConcluida()
          : this.dataConcluida,
      distanciaAlertaMetros:
          distanciaAlertaMetros ?? this.distanciaAlertaMetros,
    );
  }
}
