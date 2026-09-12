import 'package:flutter/material.dart';

import '../../../src/widgets/base_list_screen.dart';
import '../../widgets/admin_scaffold.dart';
import 'denuncia_view_model.dart';
import 'triagem_denuncias_controller.dart';

/// Visão de triagem: panorama rápido de todas as denúncias registradas,
/// para a equipe decidir o que priorizar. Para a listagem completa e
/// pesquisável, ver `ListagemDeDenunciasScreen`. Migrada para
/// `BaseListScreen` em GEOPRAG-90.
class DashboardDenunciasAdminScreen extends StatelessWidget {
  const DashboardDenunciasAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/denuncias_admin',
      appBar: AppBar(title: const Text('Gestão de Denúncias')),
      body:
          const BaseListScreen<
            TriagemDenunciasController,
            DenunciaResumoViewModel
          >(),
    );
  }
}
