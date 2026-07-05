import 'package:flutter/material.dart';

import '../widgets/sidebar_menu.dart';

class DashboardGeralScreen extends StatelessWidget {
  const DashboardGeralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visão Geral'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SidebarMenu(currentRoute: '/dashboard'),
          // Main Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  // Top Row: KPIs
                  Row(
                    children: [
                      _buildKpiCard('Estoque Crítico', '2 lotes a vencer', Icons.warning, Colors.orange),
                      const SizedBox(width: 16),
                      _buildKpiCard('Aplicações Atrasadas', '4 córregos', Icons.timer_off, Colors.red),
                      const SizedBox(width: 16),
                      _buildKpiCard('Denúncias Abertas', '12', Icons.report, Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Middle Row: Logs and Map
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Logs
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              _buildLogPanel(
                                'Atualizações de Estoque',
                                [
                                  'Lote BTI-001 perto de vencer (5 dias).',
                                  'Novo lote BTI-004 recebido hoje.',
                                ],
                                Icons.inventory_2,
                              ),
                              const SizedBox(height: 16),
                              _buildLogPanel(
                                'Últimas Aplicações',
                                [
                                  'Bairro Coloninha: Aplicação realizada.',
                                  'Bairro Margem Esquerda: Em breve (2 dias).',
                                  'Bairro Belchior: ATRASADA (20 dias).',
                                ],
                                Icons.water_drop,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right Column: Map and Denúncias
                        Expanded(
                          flex: 2,
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text('Visão Geográfica & Focos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.blue[200]!),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '[Componente de Mapa Aqui]\nExibindo divisas de bairros e\nmarcações espaciais dos focos',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.blueGrey),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text('Focos Recentes', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  const ListTile(
                                    leading: Icon(Icons.bug_report, color: Colors.red),
                                    title: Text('Foco Alto - Belchior Alto'),
                                    subtitle: Text('Status: Equipe a Investigar'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogPanel(String title, List<String> logs, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF1B5E20)),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Expanded(child: Text(logs[index], style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
