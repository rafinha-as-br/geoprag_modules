import 'package:flutter/material.dart';

import '../theme/geoprag_status.dart';

/// Badge de status pill, conforme "05 · Componentes-base" do guia de marca
/// (Em dia / Atrasado / Denúncia). Use [label] para textos dinâmicos como
/// "Faltam 5 dias" ou "ATRASADO", mantendo a semântica de cor do [status].
class GeopragStatusBadge extends StatelessWidget {
  final GeopragStatus status;
  final String? label;
  final bool dense;

  const GeopragStatusBadge({
    super.key,
    required this.status,
    this.label,
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
            label ?? status.defaultLabel,
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
