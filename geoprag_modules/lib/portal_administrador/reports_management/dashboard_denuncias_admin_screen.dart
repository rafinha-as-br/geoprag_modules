import 'package:flutter/material.dart';

import '../widgets/sidebar_menu.dart';

class DashboardDenunciasAdminScreen extends StatelessWidget {
  const DashboardDenunciasAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Denúncias'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          const SidebarMenu(currentRoute: '/denuncias_admin'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Triagem e Acompanhamento de Focos',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(labelText: 'Filtrar por Status', border: OutlineInputBorder()),
                                  items: const [
                                    DropdownMenuItem(value: 'Todas', child: Text('Todas as Denúncias')),
                                    DropdownMenuItem(value: 'Recebida', child: Text('Recebida')),
                                    DropdownMenuItem(value: 'Equipe a Investigar', child: Text('Equipe a Investigar')),
                                    DropdownMenuItem(value: 'Em Combate', child: Text('Em Combate')),
                                    DropdownMenuItem(value: 'Resolvido', child: Text('Resolvido')),
                                  ],
                                  onChanged: (v) {},
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(labelText: 'Nível de Infestação', border: OutlineInputBorder()),
                                  items: const [
                                    DropdownMenuItem(value: 'Todos', child: Text('Todos os Níveis')),
                                    DropdownMenuItem(value: 'Alto', child: Text('Alto (Prioridade)')),
                                  ],
                                  onChanged: (v) {},
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Table(
                            border: TableBorder.all(color: Colors.grey[300]!),
                            columnWidths: const {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1),
                              4: FlexColumnWidth(1),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(color: Colors.grey[100]),
                                children: const [
                                  Padding(padding: EdgeInsets.all(12), child: Text('Data', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(12), child: Text('Descrição do Local', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(12), child: Text('Nível', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(12), child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(12), child: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                              ),
                              _buildTableRow(context, '05/07/2026', 'Rua Principal (perto da ponte)', 'Alto', 'Recebida', Colors.red, Colors.blue),
                              _buildTableRow(context, '03/07/2026', 'Remanso no bairro Belchior', 'Médio', 'Equipe a Investigar', Colors.orange, Colors.orange),
                              _buildTableRow(context, '20/06/2026', 'Foco no Gasparinho', 'Baixo', 'Resolvido', Colors.green, Colors.green),
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

  TableRow _buildTableRow(BuildContext context, String data, String descricao, String nivel, String status, Color nivelColor, Color statusColor) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(data)),
        Padding(padding: const EdgeInsets.all(12), child: Text(descricao)),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(nivel, style: TextStyle(color: nivelColor, fontWeight: FontWeight.bold)),
        ),
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
              Navigator.pushNamed(context, '/denuncias_admin/detalhes');
            },
            tooltip: 'Analisar e Tratar',
          ),
        ),
      ],
    );
  }
}
