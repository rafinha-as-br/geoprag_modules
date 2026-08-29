import 'package:flutter/material.dart';

import '../../../src/widgets/base_list_screen.dart';
import '../../widgets/admin_scaffold.dart';
import 'produto_view_model.dart';
import 'produtos_cubit.dart';

/// Dashboard de Controle de Estoque e Compras — migrado para `BaseListScreen`
/// na GEOPRAG-90 (tabela crua trocada por `GeopragDataTable`, busca
/// decorativa conectada à filtragem real).
class DashboardEstoqueScreen extends StatelessWidget {
  const DashboardEstoqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/estoque',
      appBar: AppBar(title: const Text('Controle de Estoque e Compras')),
      body: const BaseListScreen<ProdutosCubit, ProdutoResumoViewModel>(),
    );
  }
}
