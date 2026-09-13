import 'package:flutter/material.dart';

import '../../../src/widgets/base_list_screen.dart';
import '../../../src/widgets/geoprag_back_button.dart';
import '../../autenticacao/core/admin_navigator.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fórmulas de Dosagem'),
        leading: GeopragBackButton(
          onBack: () => AdminNavigatorScope.of(context).toEstoque(),
        ),
      ),
      body:
          const BaseListScreen<FormulasDosagemCubit, FormulaDosagemViewModel>(),
    );
  }
}
