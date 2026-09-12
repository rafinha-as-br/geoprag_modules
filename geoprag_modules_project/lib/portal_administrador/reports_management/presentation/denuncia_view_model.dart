import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/theme/geoprag_status.dart';
import '../core/denuncia.dart';
import '../core/historico_denuncia.dart';

/// Cor de destaque do nível de infestação nas listagens (dashboard de
/// triagem e listagem completa de Denúncias).
Color corNivelInfestacao(String nivel) {
  switch (nivel) {
    case 'Alto':
      return GeopragColors.statusAtrasado;
    case 'Médio':
      return GeopragColors.statusDenuncia;
    default:
      return GeopragColors.statusEmDia;
  }
}

/// Status de badge derivado do status textual da Denúncia, usado nas
/// mesmas listagens.
GeopragStatus statusParaBadge(String status) =>
    status == 'Resolvido' ? GeopragStatus.emDia : GeopragStatus.denuncia;

String _formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}

String _formatarDataHora(DateTime data) {
  final hora = data.hour.toString().padLeft(2, '0');
  final minuto = data.minute.toString().padLeft(2, '0');
  return '${_formatarData(data)} às $hora:$minuto';
}

/// ViewModel resumida de [Denuncia] — usada nas listagens (dashboard de
/// triagem e listagem completa), antes de abrir o detalhe completo.
class DenunciaResumoViewModel {
  final String id;
  final DateTime dataHora;
  final String denunciante;
  final String descricao;
  final String nivelInfestacao;
  final String status;

  const DenunciaResumoViewModel({
    required this.id,
    required this.dataHora,
    required this.denunciante,
    required this.descricao,
    required this.nivelInfestacao,
    required this.status,
  });

  String get dataFormatada => _formatarData(dataHora);

  factory DenunciaResumoViewModel.fromEntity(Denuncia entity) {
    return DenunciaResumoViewModel(
      id: entity.id,
      dataHora: entity.dataHora,
      denunciante: entity.denunciante,
      descricao: entity.descricao,
      nivelInfestacao: entity.nivelInfestacao,
      status: entity.status,
    );
  }
}

class HistoricoDenunciaViewModel {
  final String titulo;
  final String autor;
  final DateTime dataHora;
  final String status;

  const HistoricoDenunciaViewModel({
    required this.titulo,
    required this.autor,
    required this.dataHora,
    required this.status,
  });

  String get dataHoraFormatada => _formatarDataHora(dataHora);

  factory HistoricoDenunciaViewModel.fromEntity(HistoricoDenuncia entity) {
    return HistoricoDenunciaViewModel(
      titulo: entity.titulo,
      autor: entity.autor,
      dataHora: entity.dataHora,
      status: entity.status,
    );
  }
}

/// ViewModel detalhada de [Denuncia] — dados completos do foco reportado
/// mais o histórico de auditoria (agregado de outra fonte, ver
/// [DenunciaRepository.buscarHistorico]).
class DenunciaDetalhadaViewModel {
  final String id;
  final double lat;
  final double lng;
  final DateTime dataHora;
  final String denunciante;
  final String nivelInfestacao;
  final String descricao;
  final String observacoes;
  final String status;
  final List<HistoricoDenunciaViewModel> historico;

  const DenunciaDetalhadaViewModel({
    required this.id,
    required this.lat,
    required this.lng,
    required this.dataHora,
    required this.denunciante,
    required this.nivelInfestacao,
    required this.descricao,
    required this.observacoes,
    required this.status,
    required this.historico,
  });

  String get dataHoraFormatada => _formatarDataHora(dataHora);

  factory DenunciaDetalhadaViewModel.fromEntity(
    Denuncia entity,
    List<HistoricoDenuncia> historico,
  ) {
    return DenunciaDetalhadaViewModel(
      id: entity.id,
      lat: entity.lat,
      lng: entity.lng,
      dataHora: entity.dataHora,
      denunciante: entity.denunciante,
      nivelInfestacao: entity.nivelInfestacao,
      descricao: entity.descricao,
      observacoes: entity.observacoes,
      status: entity.status,
      historico: historico.map(HistoricoDenunciaViewModel.fromEntity).toList(),
    );
  }
}
