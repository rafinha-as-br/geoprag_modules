import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../widgets/sidebar_menu.dart';

class VisualizacaoIndividualScreen extends StatelessWidget {
  const VisualizacaoIndividualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Aplicador'),
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
                        'Maria Souza',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.edit),
                            label: const Text('Editar Cadastro'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.delete),
                            label: const Text('Excluir (Lógico)'),
                            style: ElevatedButton.styleFrom(backgroundColor: GeopragColors.statusAtrasado, foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Perfil
                      Expanded(
                        flex: 1,
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Informações Pessoais', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                const Divider(),
                                const ListTile(title: Text('CPF'), subtitle: Text('123.456.789-00')),
                                const ListTile(title: Text('Telefone'), subtitle: Text('(47) 99999-9999')),
                                const ListTile(title: Text('Endereço'), subtitle: Text('Rua Principal, 100 - Gasparinho')),
                                const SizedBox(height: 16),
                                const Text('Status do Cadastro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: 'Ativo',
                                  decoration: const InputDecoration(border: OutlineInputBorder()),
                                  items: const [
                                    DropdownMenuItem(value: 'Ativo', child: Text('Ativo')),
                                    DropdownMenuItem(value: 'Desativado', child: Text('Desativado')),
                                  ],
                                  onChanged: (val) {},
                                ),
                                const SizedBox(height: 8),
                                const Text('Acesso liberado ou bloqueado ao aplicativo móvel.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Histórico
                      Expanded(
                        flex: 2,
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Histórico de Atuações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.water_drop, color: Colors.blue),
                                  title: const Text('Aplicação Concluída'),
                                  subtitle: const Text('Córrego Gasparinho - 20/06/2026'),
                                  trailing: const Text('50ml aplicados'),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.inventory_2, color: GeopragColors.statusEmDia),
                                  title: const Text('Recebimento Confirmado'),
                                  subtitle: const Text('Lote BTI-001 - 15/06/2026'),
                                  trailing: const Text('500ml recebidos'),
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
