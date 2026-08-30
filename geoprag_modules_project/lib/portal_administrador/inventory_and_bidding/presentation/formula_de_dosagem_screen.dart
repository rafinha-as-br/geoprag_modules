import 'package:flutter/material.dart';

import '../../../src/widgets/base_list_screen.dart';
import '../../widgets/admin_scaffold.dart';
import 'formulas_dosagem_cubit.dart';
import 'produto_view_model.dart';

/// Listagem das fórmulas de dosagem de BTI cadastradas por produto do
/// fabricante, usadas pela API para calcular a dosagem exata a partir da
/// vazão (Largura x Profundidade x Velocidade) do córrego. Migrada para
/// `BaseListScreen` em GEOPRAG-90.
class FormulaDeDosagemScreen extends StatelessWidget {
  const FormulaDeDosagemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/estoque',
      appBar: AppBar(title: const Text('Fórmulas de Dosagem')),
      body: const BaseListScreen<FormulasDosagemCubit, FormulaDosagemViewModel>(),
    );
  }
}
