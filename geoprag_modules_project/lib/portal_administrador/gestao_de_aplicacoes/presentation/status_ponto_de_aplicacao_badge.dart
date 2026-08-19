import 'package:flutter/material.dart';

import '../core/ponto_de_aplicacao.dart';

/// Badge de status para um ponto de aplicação (feita/planejada/atrasada).
/// Mesma linguagem visual de `GeopragStatusBadge`, mas para
/// [StatusPontoDeAplicacao], que tem semântica própria (execução do ponto,
/// não pontualidade do aplicador).
class StatusPontoDeAplicacaoBadge extends StatelessWidget {
  final StatusPontoDeAplicacao status;
  final bool dense;

  const StatusPontoDeAplicacaoBadge({
    super.key,
    required this.status,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = status.color;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 10 : 14,
        vertical: dense ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            status.defaultLabel,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: dense ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
