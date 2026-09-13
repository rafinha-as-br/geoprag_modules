import 'package:flutter/material.dart';

import '../../../../src/entities/ponto_de_aplicacao.dart';
import 'formulario_de_agendamento.dart';

/// Ativa o ciclo de um único ponto, coletando o agendamento (mesmo
/// formulário do lote — GEOPRAG-101/[FormularioDeAgendamento]). Devolve o
/// [Agendamento] via `Navigator.pop`, ou `null` se cancelado.
class AtivacaoDialog extends StatefulWidget {
  const AtivacaoDialog({
    super.key,
    required this.nomeDoPonto,
    required this.identificadorDoPonto,
  });

  final String nomeDoPonto;
  final String identificadorDoPonto;

  @override
  State<AtivacaoDialog> createState() => _AtivacaoDialogState();
}

class _AtivacaoDialogState extends State<AtivacaoDialog> {
  Agendamento? _agendamento;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ativar ciclo'),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.nomeDoPonto} · ${widget.identificadorDoPonto}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              FormularioDeAgendamento(
                onChanged: (agendamento) =>
                    setState(() => _agendamento = agendamento),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _agendamento == null
              ? null
              : () => Navigator.of(context).pop(_agendamento),
          child: const Text('Ativar'),
        ),
      ],
    );
  }
}
