import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../widgets/sidebar_menu.dart';

class MapMonitoringScreen extends StatelessWidget {
  const MapMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Hidrológico e Monitoramento'),
      ),
      body: Row(
        children: [
          const SidebarMenu(currentRoute: '/mapa'),
          // Main Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Mapa do Município',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selecione um bairro no mapa para visualizar a situação dos córregos e aplicações.',
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      children: [
                        // Left: Map
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Stack(
                              children: [
                                const Center(
                                  child: Text(
                                    '[Mapa Interativo de Gaspar]\nBairros clicáveis',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.green, fontSize: 18),
                                  ),
                                ),
                                // Mock Pin
                                Positioned(
                                  top: 100,
                                  left: 200,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/mapa/bairro');
                                    },
                                    child: const Column(
                                      children: [
                                        Icon(Icons.location_on, color: GeopragColors.statusAtrasado, size: 48),
                                        Text('Belchior Alto (Atrasado)', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 200,
                                  left: 350,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/mapa/bairro');
                                    },
                                    child: const Column(
                                      children: [
                                        Icon(Icons.location_on, color: GeopragColors.statusEmDia, size: 48),
                                        Text('Gasparinho', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right: Legend & List
                        Expanded(
                          flex: 1,
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text('Legenda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  const SizedBox(height: 16),
                                  const ListTile(
                                    leading: Icon(Icons.location_on, color: GeopragColors.statusEmDia),
                                    title: Text('Em dia (verde)'),
                                    dense: true,
                                  ),
                                  const ListTile(
                                    leading: Icon(Icons.location_on, color: GeopragColors.statusAtrasado),
                                    title: Text('Atrasado (vermelho)'),
                                    dense: true,
                                  ),
                                  const ListTile(
                                    leading: Icon(Icons.location_on, color: GeopragColors.statusDenuncia),
                                    title: Text('Foco Reportado (amarelo)'),
                                    dense: true,
                                  ),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  const Text('Alertas Críticos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: GeopragColors.statusAtrasado)),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: ListView(
                                      children: [
                                        ListTile(
                                          title: const Text('Córrego da Onça (Belchior Alto)'),
                                          subtitle: const Text('25 dias sem aplicação'),
                                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                                          onTap: () {
                                            Navigator.pushNamed(context, '/mapa/bairro');
                                          },
                                        ),
                                      ],
                                    ),
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
}
