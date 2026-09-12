import 'package:flutter/material.dart';

import '../../../src/widgets/base_list_screen.dart';
import '../../widgets/admin_scaffold.dart';
import 'administradores_cubit.dart';
import 'administrador_view_model.dart';

/// Dashboard do módulo Gerenciamento de Administradores (GEOPRAG-36):
/// listagem com busca, desativação de cadastro e solicitação de promoção
/// de Sub-Administrador. Migrada para `BaseListScreen` na GEOPRAG-90 — a
/// ação "Ver detalhes" (antes por toque na linha) virou uma coluna
/// dedicada, no mesmo padrão das demais telas migradas no épico.
class DashboardAdministradoresScreen extends StatelessWidget {
  const DashboardAdministradoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/administradores',
      appBar: AppBar(title: const Text('Gerenciamento de Administradores')),
      body: const BaseListScreen<AdministradoresCubit, AdministradorViewModel>(),
    );
  }
}
