import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../core/aplicador_navigator.dart';

class RecebimentosScreen extends StatelessWidget {
  const RecebimentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recebimentos Pendentes')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Selecione o produto para confirmar o recebimento:',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GeopragColors.neutralLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.science_outlined,
                  color: GeopragColors.green900,
                ),
              ),
              title: const Text(
                'BTI Líquido - 1 Litro',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Enviado por: João Silva (Prefeitura)\nData: 05/07/2026',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                AplicadorNavigatorScope.of(context).toRecebimentoConfirmar();
              },
            ),
          ),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GeopragColors.neutralLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.science_outlined,
                  color: GeopragColors.green900,
                ),
              ),
              title: const Text(
                'BTI Sólido - 500g',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Enviado por: João Silva (Prefeitura)\nData: 03/07/2026',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                AplicadorNavigatorScope.of(context).toRecebimentoConfirmar();
              },
            ),
          ),
        ],
      ),
    );
  }
}
