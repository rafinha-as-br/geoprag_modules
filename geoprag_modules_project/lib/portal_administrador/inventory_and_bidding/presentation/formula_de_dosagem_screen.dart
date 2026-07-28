import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/sidebar_menu.dart';
import 'formulas_dosagem_cubit.dart';
import 'formulas_dosagem_state.dart';
import 'produto_view_model.dart';

/// Listagem das fórmulas de dosagem de BTI cadastradas por produto do
/// fabricante, usadas pela API para calcular a dosagem exata a partir da
/// vazão (Largura x Profundidade x Velocidade) do córrego.
class FormulaDeDosagemScreen extends StatelessWidget {
  const FormulaDeDosagemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fórmulas de Dosagem')),
      body: Row(
        children: [
          const SidebarMenu(currentRoute: '/estoque'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Fórmulas de Dosagem por Produto',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                        label: const Text('Nova Fórmula'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cada fórmula é repassada à API para calcular a dosagem '
                    'exata com base na vazão medida do córrego.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: BlocBuilder<
                          FormulasDosagemCubit,
                          FormulasDosagemState
                        >(
                          builder: (context, state) {
                            return switch (state) {
                              FormulasDosagemLoading() => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              FormulasDosagemError(:final message) => Center(
                                child: Text(
                                  'Não foi possível carregar as fórmulas: $message',
                                ),
                              ),
                              FormulasDosagemLoaded(:final formulas) => Table(
                                border: TableBorder.all(
                                  color: Colors.grey[300]!,
                                ),
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(1),
                                  3: FlexColumnWidth(1),
                                  4: FlexColumnWidth(1),
                                },
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                    ),
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Text(
                                          'Produto',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Text(
                                          'Fator de Conversão',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Text(
                                          'Distância de Carreamento',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Text(
                                          'Fator de Correção',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Text(
                                          'Ações',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  for (final formula in formulas)
                                    _buildTableRow(formula),
                                ],
                              ),
                            };
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(FormulaDosagemViewModel formula) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(formula.produtoNome),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('${formula.fatorConversao} ml/m³/s'),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('${formula.distanciaCarreamento.toStringAsFixed(0)} m'),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('${formula.fatorCorrecao}'),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {},
            tooltip: 'Editar',
          ),
        ),
      ],
    );
  }
}
