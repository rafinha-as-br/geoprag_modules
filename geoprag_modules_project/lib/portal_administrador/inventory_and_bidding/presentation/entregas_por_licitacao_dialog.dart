import 'package:flutter/material.dart';

import 'produto_view_model.dart';

/// Mostra, por licitação, as entregas parciais já recebidas (GEOPRAG-163).
Future<void> mostrarEntregasPorLicitacao(
  BuildContext context,
  List<EntregasLicitacaoViewModel> licitacoes,
) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Entregas por Licitação'),
      content: SizedBox(
        width: 560,
        child: licitacoes.isEmpty
            ? const Text('Nenhuma entrega registrada.')
            : ListView(
                shrinkWrap: true,
                children: [for (final l in licitacoes) _LicitacaoEntregas(l)],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Fechar'),
        ),
      ],
    ),
  );
}

class _LicitacaoEntregas extends StatelessWidget {
  const _LicitacaoEntregas(this.licitacao);

  final EntregasLicitacaoViewModel licitacao;

  @override
  Widget build(BuildContext context) {
    final total = licitacao.totalPorUnidade.entries
        .map((e) => '${e.value} ${e.key}')
        .join(' + ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${licitacao.licitacao} — ${licitacao.entregas.length} '
            'entrega(s), $total recebidos',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          for (final e in licitacao.entregas)
            Text(
              '${e.nome} — Lote ${e.lote} — ${e.quantidadeOriginal} '
              '${e.unidadeMedida} — validade ${_data(e.dataValidade)}',
            ),
        ],
      ),
    );
  }

  static String _data(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
