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

    return SizedBox(
      width: 250,
      // `Material` em vez de `Container(color: ...)`: um `ColoredBox` (o
      // que `Container.color` cria por baixo dos panos) entre os `ListTile`
      // de módulo e o `Material` ancestor mais próximo esconde o highlight
      // de seleção e o splash de toque deles — `Material` já é, ele mesmo,
      // um ancestor válido, então pinta o fundo sem esconder nada.
      child: Material(
        color: Colors.grey[100],
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(color: GeopragColors.green900),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: GeopragLogo(
                          markSize: 32,
                          variant: GeopragMarkVariant.light,
                        ),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    'Visão Geral',
                    Icons.dashboard,
                    '/dashboard',
                  ),
                  _buildMenuItem(
                    context,
                    'Gestão de Aplicações',
                    Icons.pin_drop,
                    '/aplicacoes',
                  ),
                  _buildMenuItem(
                    context,
                    'Aplicadores',
                    Icons.people,
                    '/aplicadores',
                  ),
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
                ],
              ),
            ),
            // Fora do ListView rolável: fica fixo no rodapé enquanto os itens
            // de módulo acima rolam (GEOPRAG-146).
            if (sessionState is AdminSessionAutenticado)
              _ContaFooter(conta: sessionState.conta),
          ],
        ),
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
      case '/aplicacoes':
        navigator.toAplicacoes();
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

/// Botão de conta fixo no rodapé do [SidebarMenu], substituindo o antigo
/// `ListTile` "Sair" solto no fim da lista (GEOPRAG-146, base do épico
/// GEOPRAG-139).
///
/// Abre um menu ancorado **para cima** — o mesmo comportamento do botão de
/// conta do app desktop do Claude. Não é posicionamento manual: o
/// `MenuAnchor` do Flutter já cresce para cima sozinho quando não há espaço
/// abaixo do anchor, e como este botão fica colado na borda inferior da
/// tela, esse é sempre o caso aqui.
///
/// Tem "Editar dados" (GEOPRAG-148) e "Sair da conta". "Configurações" e
/// "Suporte" ficam de fora até ganharem destino definido (decisão explícita
/// de Rafinha em GEOPRAG-149) — não é esquecimento, é para não deixar item
/// de menu sem lugar nenhum para ir.
class _ContaFooter extends StatelessWidget {
  const _ContaFooter({required this.conta});

  final AdminAccount conta;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1),
        MenuAnchor(
          alignmentOffset: const Offset(0, -8),
          menuChildren: [
            MenuItemButton(
              leadingIcon: const Icon(Icons.edit),
              onPressed: () =>
                  AdminNavigatorScope.of(context).toEditarMeusDados(),
              child: const Text('Editar dados'),
            ),
            MenuItemButton(
              leadingIcon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AdminSessionCubit>().encerrarSessao();
                AdminNavigatorScope.of(context).toLogout();
              },
              child: const Text('Sair da conta'),
            ),
          ],
          builder: (context, controller, child) {
            return InkWell(
              key: const Key('sidebar_conta_footer_botao'),
              onTap: () =>
                  controller.isOpen ? controller.close() : controller.open(),
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: GeopragColors.green900,
                  foregroundColor: Colors.white,
                  child: Text(_iniciais(conta.nome)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        conta.nome,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        conta.role.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.expand_less),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _iniciais(String nome) {
    final partes = nome
        .trim()
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .toList();
    if (partes.isEmpty) return '?';
    final primeira = partes.first[0];
    final ultima = partes.length > 1 ? partes.last[0] : '';
    return (primeira + ultima).toUpperCase();
  }
}
