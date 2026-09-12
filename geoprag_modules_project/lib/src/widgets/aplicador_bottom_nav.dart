import 'package:flutter/material.dart';

import '../../aplicador_app/core/aplicador_navigator.dart';
import '../theme/geoprag_colors.dart';

/// Bottom navigation compartilhado entre as telas principais do app do
/// aplicador (Início/Insumos/Denúncias) — mesmos itens, cores e lógica de
/// navegação hoje duplicados em `visualizacao_do_ponto_screen.dart`,
/// `lista_de_insumos_screen.dart` e `dashboard_de_focos_screen.dart`.
///
/// Recebe [currentIndex] — a aba correspondente à tela atual — como
/// parâmetro explícito (em vez de estado interno, que nas telas originais
/// nunca refletia de fato a tela atual) e usa o [AplicadorNavigator] do
/// [AplicadorNavigatorScope] para navegar ao tocar em outra aba, sem
/// re-navegar para a própria tela atual.
class AplicadorBottomNav extends StatelessWidget {
  final int currentIndex;

  const AplicadorBottomNav({super.key, required this.currentIndex});

  static const _items = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
    BottomNavigationBarItem(
      icon: Icon(Icons.inventory_2_outlined),
      label: 'Insumos',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.report_problem_outlined),
      label: 'Denúncias',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: GeopragColors.green900,
      unselectedItemColor: Colors.grey,
      items: _items,
      onTap: (index) {
        if (index == currentIndex) return;
        final navigator = AplicadorNavigatorScope.of(context);
        switch (index) {
          case 0:
            navigator.toPonto();
          case 1:
            navigator.toInventario();
          case 2:
            navigator.toDenuncias();
        }
      },
    );
  }
}
