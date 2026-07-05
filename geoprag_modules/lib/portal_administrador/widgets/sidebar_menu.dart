import 'package:flutter/material.dart';

class SidebarMenu extends StatelessWidget {
  final String currentRoute;

  const SidebarMenu({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey[100],
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1B5E20)),
            child: Center(
              child: Text(
                'GeoPrag\nAdmin',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          _buildMenuItem(context, 'Visão Geral', Icons.dashboard, '/dashboard'),
          _buildMenuItem(context, 'Mapa Hidrológico', Icons.map, '/mapa'),
          _buildMenuItem(context, 'Aplicadores', Icons.people, '/aplicadores'),
          _buildMenuItem(context, 'Estoque e Compras', Icons.inventory, '/estoque'),
          _buildMenuItem(context, 'Distribuições', Icons.local_shipping, '/distribuicoes'),
          _buildMenuItem(context, 'Denúncias', Icons.report_problem, '/denuncias_admin'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, String route) {
    final isActive = currentRoute == route || currentRoute.startsWith('$route/');
    final activeColor = const Color(0xFF1B5E20);

    return ListTile(
      leading: Icon(icon, color: isActive ? activeColor : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? activeColor : null,
        ),
      ),
      selected: isActive,
      selectedTileColor: activeColor.withOpacity(0.1),
      onTap: () {
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}
