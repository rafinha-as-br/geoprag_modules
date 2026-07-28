import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../src/theme/geoprag_colors.dart';
import '../../src/widgets/geoprag_logo.dart';
import '../autenticacao/core/admin_account.dart';
import '../autenticacao/core/admin_navigator.dart';
import '../autenticacao/presentation/admin_session_cubit.dart';
import '../autenticacao/presentation/admin_session_state.dart';

class SidebarMenu extends StatelessWidget {
  final String currentRoute;

  const SidebarMenu({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final sessionState = context.watch<AdminSessionCubit>().state;
    final isAdministrador =
        sessionState is AdminSessionAutenticado &&
        sessionState.conta.role == AdminRole.administrador;

    return Container(
      width: 250,
      color: Colors.grey[100],
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: GeopragColors.green900),
            child: Center(
              child: GeopragLogo(
                markSize: 32,
                variant: GeopragMarkVariant.light,
              ),
            ),
          ),
          _buildMenuItem(context, 'Visão Geral', Icons.dashboard, '/dashboard'),
          _buildMenuItem(context, 'Mapa Hidrológico', Icons.map, '/mapa'),
          _buildMenuItem(context, 'Aplicadores', Icons.people, '/aplicadores'),
          _buildMenuItem(
            context,
            'Estoque e Compras',
            Icons.inventory,
            '/estoque',
          ),
          _buildMenuItem(
            context,
            'Distribuições',
            Icons.local_shipping,
            '/distribuicoes',
          ),
          _buildMenuItem(
            context,
            'Denúncias',
            Icons.report_problem,
            '/denuncias_admin',
          ),
          // Ocultação total (não apenas bloqueio de rota) para
          // Sub-Administrador — GEOPRAG-36, escopo 3.
          if (isAdministrador)
            _buildMenuItem(
              context,
              'Gerenciamento de Administradores',
              Icons.admin_panel_settings,
              '/administradores',
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () {
              context.read<AdminSessionCubit>().encerrarSessao();
              AdminNavigatorScope.of(context).toLogout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    final isActive =
        currentRoute == route || currentRoute.startsWith('$route/');
    final activeColor = GeopragColors.green900;

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
      selectedTileColor: activeColor.withValues(alpha: 0.1),
      onTap: () {
        if (!isActive) {
          _navigateToSection(context, route);
        }
      },
    );
  }

  void _navigateToSection(BuildContext context, String route) {
    final navigator = AdminNavigatorScope.of(context);
    switch (route) {
      case '/dashboard':
        navigator.toDashboard();
      case '/mapa':
        navigator.toMapa();
      case '/aplicadores':
        navigator.toAplicadores();
      case '/estoque':
        navigator.toEstoque();
      case '/distribuicoes':
        navigator.toDistribuicoes();
      case '/denuncias_admin':
        navigator.toDenunciasAdmin();
      case '/administradores':
        navigator.toGerenciamentoAdministradores();
    }
  }
}
