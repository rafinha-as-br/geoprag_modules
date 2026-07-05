import 'package:flutter/material.dart';

import '../widgets/sidebar_menu.dart';

class DashboardEstoqueScreen extends StatelessWidget {
  const DashboardEstoqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Estoque e Compras'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          const SidebarMenu(currentRoute: '/estoque'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Inventário Geral',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/estoque/formula');
                            },
                            icon: const Icon(Icons.calculate),
                            label: const Text('Fórmula de Dosagem'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/estoque/licitacao');
                            },
                            icon: const Icon(Icons.description),
                            label: const Text('Nova Licitação'),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/estoque/produto');
                            },
                            icon: const Icon(Icons.add_box),
                            label: const Text('Registrar Entrada'),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Buscar produto por lote ou licitação...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Table(
                              border: TableBorder.all(color: Colors.grey[300]!),
                              columnWidths: const {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(1),
                                2: FlexColumnWidth(1),
                                3: FlexColumnWidth(1),
                                4: FlexColumnWidth(1),
                              },
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(color: Colors.grey[100]),
                                  children: const [
                                    Padding(padding: EdgeInsets.all(12), child: Text('Produto / Lote', style: TextStyle(fontWeight: FontWeight.bold))),
                                    Padding(padding: EdgeInsets.all(12), child: Text('Licitação', style: TextStyle(fontWeight: FontWeight.bold))),
                                    Padding(padding: EdgeInsets.all(12), child: Text('Estoque Atual', style: TextStyle(fontWeight: FontWeight.bold))),
                                    Padding(padding: EdgeInsets.all(12), child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                    Padding(padding: EdgeInsets.all(12), child: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                ),
                                _buildTableRow(context, 'BTI Líquido - Lote BTI-001', 'Pregão 01/2026', '100 Litros', 'Em estoque', Colors.green),
                                _buildTableRow(context, 'BTI Sólido - Lote BTI-002', 'Pregão 01/2026', '5 Kg', 'Perto do Venc.', Colors.orange),
                                _buildTableRow(context, 'BTI Líquido - Lote 999', 'Pregão 10/2025', '0 Litros', 'Esgotado', Colors.grey),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(BuildContext context, String produto, String licitacao, String estoque, String status, Color statusColor) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(produto)),
        Padding(padding: const EdgeInsets.all(12), child: Text(licitacao)),
        Padding(padding: const EdgeInsets.all(12), child: Text(estoque)),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: IconButton(
            icon: const Icon(Icons.visibility, color: Colors.blue),
            onPressed: () {
              Navigator.pushNamed(context, '/estoque/visualizacao');
            },
          ),
        ),
      ],
    );
  }
}
