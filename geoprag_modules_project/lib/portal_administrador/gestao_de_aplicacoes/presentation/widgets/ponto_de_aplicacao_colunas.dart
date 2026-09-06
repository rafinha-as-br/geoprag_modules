import 'package:flutter/material.dart';

import '../../../../src/widgets/geoprag_status_badge.dart';
import '../../../gerenciamento_de_administradores/presentation/widgets/geoprag_data_table.dart';
import '../ponto_de_aplicacao_view_model.dart';

/// Colunas da listagem de Pontos de Aplicação, compartilhadas pelo dashboard
/// e pela tela de bairro — as duas listam a mesma entidade e só divergem em
/// [exibirBairro], que não faz sentido dentro de um bairro só.
///
/// Não há coluna de próxima aplicação: a data de agendamento entra junto com
/// o agendamento em si, na issue de ações individuais da sprint. Uma coluna
/// vazia até lá seria informação decorativa.
List<GeopragDataColumn<PontoDeAplicacaoResumoViewModel>>
colunasDePontoDeAplicacao({required bool exibirBairro}) {
  return [
    GeopragDataColumn(
      label: 'Ponto',
      width: const FlexColumnWidth(3),
      cellBuilder: (context, ponto) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(ponto.nome),
          Text(
            ponto.identificador,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    ),
    if (exibirBairro)
      GeopragDataColumn(
        label: 'Bairro',
        width: const FlexColumnWidth(2),
        cellBuilder: (context, ponto) => Text(ponto.bairro),
      ),
    GeopragDataColumn(
      label: 'Estado',
      width: const FlexColumnWidth(2),
      cellBuilder: (context, ponto) => GeopragStatusBadge(
        status: ponto.estado.status,
        label: ponto.estado.rotulo,
        dense: true,
      ),
    ),
    GeopragDataColumn(
      label: 'Aplicador',
      width: const FlexColumnWidth(2),
      cellBuilder: (context, ponto) => Text(
        ponto.aplicadorNome ?? 'Não direcionado',
        style: ponto.aplicadorNome == null
            ? const TextStyle(color: Colors.black54)
            : null,
      ),
    ),
    GeopragDataColumn(
      label: 'Execuções',
      width: const FlexColumnWidth(1),
      cellBuilder: (context, ponto) => Text(
        '${ponto.execucoesRegistradas}/${ponto.quantidadeDeSubpontos}',
      ),
    ),
  ];
}
