import 'package:flutter/material.dart';

import 'sidebar_menu.dart';

/// Layout padrão das telas internas do Portal Administrador: sidebar fixo à
/// esquerda, ocupando a altura toda, e um `Scaffold` próprio (com sua
/// `AppBar`) só no painel de conteúdo à direita — a `AppBar` não cobre a
/// largura toda por cima do sidebar.
class AdminScaffold extends StatelessWidget {
  final String currentRoute;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;

  const AdminScaffold({
    super.key,
    required this.currentRoute,
    this.appBar,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SidebarMenu(currentRoute: currentRoute),
          Expanded(
            child: Scaffold(
              appBar: appBar,
              floatingActionButton: floatingActionButton,
              body: body,
            ),
          ),
        ],
      ),
    );
  }
}
