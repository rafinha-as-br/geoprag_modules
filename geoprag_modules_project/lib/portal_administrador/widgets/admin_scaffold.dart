import 'package:flutter/material.dart';

import 'sidebar_menu.dart';

/// Layout padrão das telas internas do Portal Administrador: sidebar fixo à
/// esquerda, ocupando a altura toda, e o `Scaffold` próprio de cada tela (com
/// sua `AppBar`) só no painel de conteúdo à direita — a `AppBar` não cobre a
/// largura toda por cima do sidebar.
///
/// Montado uma única vez pelo `ShellRoute` do `go_router` (GEOPRAG-116): o
/// sidebar vive fora do `Navigator` de conteúdo, então troca de rota entre
/// telas do Portal não recria nem reanima o sidebar — só [child] (a página da
/// rota atual) é substituído.
class AdminScaffold extends StatelessWidget {
  final String currentRoute;
  final Widget child;

  const AdminScaffold({
    super.key,
    required this.currentRoute,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SidebarMenu(currentRoute: currentRoute),
          Expanded(child: child),
        ],
      ),
    );
  }
}
