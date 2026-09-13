import 'package:flutter/material.dart';

import '../../../../src/entities/ponto_de_aplicacao.dart';

/// Confirmação de desativação de um ponto (GEOPRAG-110): explica, nesta
/// ordem, que não é exclusão, que o histórico é preservado, que o ponto
/// some das listas/mapa (exceto com o filtro "incluir desativados") e que é
/// reativável a qualquer momento, voltando ao estado em que estava. Quando
/// há um [agendamento] vigente com datas ainda pendentes, mostra em
/// destaque quantas serão canceladas e o aviso de push ao aplicador.
///
/// Devolve `true` se confirmado, `false`/`null` se cancelado.
Future<bool> showDesativarDialog(
  BuildContext context, {
  required Agendamento? agendamento,
}) async {
  final datasPendentes =
      agendamento?.datas
          .where((d) => d.status == StatusDataAgendada.pendente)
          .length ??
      0;

  final confirmado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Desativar ponto'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ItemDaLista(texto: 'Não é uma exclusão.'),
            const _ItemDaLista(
              texto: 'O histórico de execuções é preservado.',
            ),
            const _ItemDaLista(
              texto:
                  'O ponto some das listas e do mapa, exceto com o filtro '
                  '"incluir desativados" ligado.',
            ),
            const _ItemDaLista(
              texto: 'Reativável a qualquer momento — volta ao estado em que estava.',
            ),
            if (datasPendentes > 0) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$datasPendentes data(s) futura(s) do agendamento '
                      'será(ão) cancelada(s).',
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'O aplicador responsável será avisado.',
                      style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Desativar'),
        ),
      ],
    ),
  );
  return confirmado ?? false;
}

class _ItemDaLista extends StatelessWidget {
  const _ItemDaLista({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}
