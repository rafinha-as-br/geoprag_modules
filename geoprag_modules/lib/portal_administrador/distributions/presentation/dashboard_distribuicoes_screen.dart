import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../widgets/sidebar_menu.dart';

class DashboardDistribuicoesScreen extends StatelessWidget {
  const DashboardDistribuicoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Distribuições (Saídas)'),
      ),
      body: Row(
        children: [
          const SidebarMenu(currentRoute: '/distribuicoes'),
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
                        'Histórico de Saídas',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/distribuicoes/cadastro');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Nova Saída'),
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
                        child: ListView(
                          children: [
                            ListTile(
                              leading: const CircleAvatar(backgroundColor: GeopragColors.statusEmDia, child: Icon(Icons.local_shipping, color: Colors.white)),
                              title: const Text('Lote BTI-001 - 10 Litros', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: const Text('Para: João Silva (Líder Belchior)\nData: 05/07/2026'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                Navigator.pushNamed(context, '/distribuicoes/visualizacao');
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: const CircleAvatar(backgroundColor: GeopragColors.statusEmDia, child: Icon(Icons.local_shipping, color: Colors.white)),
                              title: const Text('Lote BTI-002 - 5 Litros', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: const Text('Para: Maria Souza (Gasparinho)\nData: 20/06/2026'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                Navigator.pushNamed(context, '/distribuicoes/visualizacao');
                              },
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
}
