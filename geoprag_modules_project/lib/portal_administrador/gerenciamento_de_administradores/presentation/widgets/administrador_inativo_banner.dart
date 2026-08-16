import 'package:flutter/material.dart';

import '../../../../src/theme/geoprag_status.dart';

/// Banner de aviso exibido no dialog de detalhes quando o cadastro do
/// administrador está desativado — extraído de `_AdministradorDetalheDialog`
/// (feedback de revisão do PR #9).
class AdministradorInativoBanner extends StatelessWidget {
  final String desdeLabel;

  const AdministradorInativoBanner({super.key, required this.desdeLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GeopragStatus.atrasado.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.block, color: GeopragStatus.atrasado.color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Este cadastro está desativado desde $desdeLabel.',
              style: TextStyle(color: GeopragStatus.atrasado.color),
            ),
          ),
        ],
      ),
    );
  }
}
