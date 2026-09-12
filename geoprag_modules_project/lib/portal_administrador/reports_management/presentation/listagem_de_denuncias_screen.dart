import 'package:flutter/material.dart';

import '../../../src/widgets/base_list_screen.dart';
import '../../widgets/admin_scaffold.dart';
import 'denuncia_view_model.dart';
import 'listagem_denuncias_controller.dart';

/// Listagem completa e pesquisável de todas as Denúncias registradas
/// (histórico completo, com filtro por status/nível e busca textual),
/// diferente do panorama de triagem em `DashboardDenunciasAdminScreen`.
/// Migrada para `BaseListScreen` em GEOPRAG-90.
class ListagemDeDenunciasScreen extends StatelessWidget {
  const ListagemDeDenunciasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/denuncias_admin',
      appBar: AppBar(title: const Text('Listagem de Denúncias')),
      body:
          const BaseListScreen<
            ListagemDenunciasController,
            DenunciaResumoViewModel
          >(),
    );
  }
}
