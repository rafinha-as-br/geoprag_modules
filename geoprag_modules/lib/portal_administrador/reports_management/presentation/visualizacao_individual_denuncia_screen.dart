import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../widgets/sidebar_menu.dart';

class VisualizacaoIndividualDenunciaScreen extends StatelessWidget {
  const VisualizacaoIndividualDenunciaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Análise da Denúncia')),
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
                    'Detalhes do Foco Reportado',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Detalhes da Denúncia
                      Expanded(
                        flex: 1,
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Informações Originais',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const Divider(),
                                const ListTile(
                                  title: Text('Data e Hora'),
                                  subtitle: Text('05/07/2026 às 14:30'),
                                ),
                                const ListTile(
                                  title: Text('Denunciante'),
                                  subtitle: Text(
                                    'João Silva (Voluntário Belchior)',
                                  ),
                                ),
                                const ListTile(
                                  title: Text('Nível de Infestação'),
                                  subtitle: Text(
                                    'Alto',
                                    style: TextStyle(
                                      color: GeopragColors.statusAtrasado,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const ListTile(
                                  title: Text('Descrição do Local'),
                                  subtitle: Text(
                                    'Rua Principal (perto da ponte, na corredeira)',
                                  ),
                                ),
                                const ListTile(
                                  title: Text('Observações Extras'),
                                  subtitle: Text(
                                    'Muita espuma natural, moradores reclamando.',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blue[200]!,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '[Mapa estático com Pin GPS]',
                                      style: TextStyle(color: Colors.blueGrey),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Gestão de Status e Histórico
                      Expanded(
                        flex: 1,
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ações Resolutivas e Status',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const Divider(),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: 'Recebida',
                                  decoration: const InputDecoration(
                                    labelText: 'Status Atual',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Recebida',
                                      child: Text('Recebida'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Equipe a Investigar',
                                      child: Text('Equipe a Investigar'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Em Combate',
                                      child: Text('Em Combate'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Resolvido',
                                      child: Text('Resolvido'),
                                    ),
                                  ],
                                  onChanged: (val) {},
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.save),
                                  label: const Text('Atualizar Status'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                const Text(
                                  'Histórico de Auditoria',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const Divider(),
                                Expanded(
                                  child: ListView(
                                    children: const [
                                      ListTile(
                                        leading: Icon(
                                          Icons.history,
                                          color: Colors.grey,
                                        ),
                                        title: Text('Criada via App Mobile'),
                                        subtitle: Text(
                                          'Por: João Silva em 05/07/2026 14:30\nStatus: Recebida',
                                        ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
