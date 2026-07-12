import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../../widgets/sidebar_menu.dart';

class DashboardAplicadoresScreen extends StatelessWidget {
  const DashboardAplicadoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Aplicadores'),
      ),
      body: Row(
        children: [
          const SidebarMenu(currentRoute: '/aplicadores'),
          // Main Content
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
                        'Voluntários Cadastrados',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                        label: const Text('Novo Aplicador'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Buscar por nome, bairro ou status...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Table(
                            border: TableBorder.all(color: Colors.grey[300]!),
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(color: Colors.grey[100]),
                                children: const [
                                  Padding(padding: EdgeInsets.all(12), child: Text('Nome', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(12), child: Text('Bairro/Trecho', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(12), child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(12), child: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                              ),
                              _buildTableRow(context, 'João Silva', 'Belchior Alto', 'Ativo', GeopragStatus.emDia),
                              _buildTableRow(context, 'Maria Souza', 'Gasparinho', 'Desativado', GeopragStatus.atrasado),
                              _buildTableRow(context, 'José Mendes', 'Bateias', 'Ativo', GeopragStatus.emDia),
                            ],
                          ),
                        ],
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

  TableRow _buildTableRow(BuildContext context, String nome, String bairro, String status, GeopragStatus statusValue) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(nome)),
        Padding(padding: const EdgeInsets.all(12), child: Text(bairro)),
        Padding(
          padding: const EdgeInsets.all(12),
          child: GeopragStatusBadge(status: statusValue, label: status, dense: true),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.blue),
                onPressed: () {
                  Navigator.pushNamed(context, '/aplicadores/detalhes');
                },
                tooltip: 'Visualizar',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
