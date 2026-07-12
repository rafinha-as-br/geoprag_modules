import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_colors.dart';

class DashboardDeFocosScreen extends StatelessWidget {
  const DashboardDeFocosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Denúncias de Foco'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: GeopragColors.green900,
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/denuncia/educativa');
              },
              icon: const Icon(Icons.add_alert),
              label: const Text('Criar Nova Denúncia'),
              style: ElevatedButton.styleFrom(
                backgroundColor: GeopragColors.white,
                foregroundColor: GeopragColors.green900,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Suas denúncias recentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: const ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: GeopragColors.statusDenuncia,
                      child: Icon(Icons.warning, color: Colors.white),
                    ),
                    title: Text('Foco Alto - Rua Principal', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Status: Recebida\nData: 05/07/2026'),
                  ),
                ),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: const ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: GeopragColors.statusEmDia,
                      child: Icon(Icons.check, color: Colors.white),
                    ),
                    title: Text('Foco Médio - Remanso', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Status: Atendida\nData: 20/06/2026'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Denúncias tab
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/ponto');
          if (index == 1) Navigator.pushReplacementNamed(context, '/inventario');
        },
        selectedItemColor: GeopragColors.green900,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Insumos'),
          BottomNavigationBarItem(icon: Icon(Icons.report_problem_outlined), label: 'Denúncias'),
        ],
      ),
    );
  }
}
