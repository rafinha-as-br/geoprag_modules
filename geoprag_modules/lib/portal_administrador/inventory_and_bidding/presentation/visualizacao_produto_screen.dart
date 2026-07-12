import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_colors.dart';

class VisualizacaoProdutoScreen extends StatelessWidget {
  const VisualizacaoProdutoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Produto no Estoque'),
      ),
      body: Center(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(32.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('BTI Líquido - Lote BTI-001', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.delete, color: GeopragColors.statusAtrasado), onPressed: () {}),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  const ListTile(
                    title: Text('Licitação Vinculada', style: TextStyle(color: Colors.grey)),
                    subtitle: Text('Pregão Eletrônico 01/2026', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const ListTile(
                    title: Text('Fornecedor', style: TextStyle(color: Colors.grey)),
                    subtitle: Text('BioInsumos Ltda.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const ListTile(
                    title: Text('Quantidade Original', style: TextStyle(color: Colors.grey)),
                    subtitle: Text('1000 Litros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const ListTile(
                    title: Text('Estoque Atual Disponível', style: TextStyle(color: Colors.grey)),
                    subtitle: Text('100 Litros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: GeopragColors.statusEmDia)),
                  ),
                  const ListTile(
                    title: Text('Validade', style: TextStyle(color: Colors.grey)),
                    subtitle: Text('31/12/2028', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 32),
                  const Text('Deduções Recentes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.arrow_downward, color: GeopragColors.statusAtrasado),
                    title: const Text('Saída para Belchior Alto'),
                    subtitle: const Text('10 Litros (Resp: João Silva) - 05/07/2026'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.arrow_downward, color: GeopragColors.statusAtrasado),
                    title: const Text('Saída para Gasparinho'),
                    subtitle: const Text('5 Litros (Resp: Maria Souza) - 20/06/2026'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
