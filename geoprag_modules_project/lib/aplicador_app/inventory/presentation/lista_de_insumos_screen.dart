import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/aplicador_bottom_nav.dart';
import '../../../src/widgets/base_card_list_screen.dart';
import '../../core/aplicador_navigator.dart';
import 'insumo_view_model.dart';
import 'inventario_cubit.dart';
import 'inventario_state.dart';

class ListaDeInsumosScreen extends StatelessWidget {
  const ListaDeInsumosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventário')),
      body: BlocBuilder<InventarioCubit, InventarioState>(
        builder: (context, state) {
          return BaseCardListScreen<EstoqueAtualViewModel>(
            model: BaseCardListScreenModel(
              isLoading: state is InventarioLoading,
              errorMessage: state is InventarioError
                  ? 'Não foi possível carregar o inventário: ${state.message}'
                  : null,
              items: state is InventarioLoaded ? [state.estoqueAtual] : null,
              itemBuilder: (context, estoqueAtual) =>
                  _InventarioConteudo(estoqueAtual: estoqueAtual),
              separatorBuilder: (context, index) => const SizedBox(),
            ),
          );
        },
      ),
      bottomNavigationBar: const AplicadorBottomNav(currentIndex: 1),
    );
  }
}

class _InventarioConteudo extends StatelessWidget {
  const _InventarioConteudo({required this.estoqueAtual});

  final EstoqueAtualViewModel estoqueAtual;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current Stock Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.inventory,
                    size: 48,
                    color: GeopragColors.green900,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Estoque Atual',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    estoqueAtual.quantidadeFormatada,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: GeopragColors.green900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${estoqueAtual.produtoNome} - '
                    '${estoqueAtual.atualizadoEmDescricao}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Ações',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Pending Deliveries Button
          InkWell(
            onTap: () {
              // Navigate to pending deliveries (Recebimentos)
              AplicadorNavigatorScope.of(context).toRecebimentos();
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GeopragColors.neutralLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: GeopragColors.green500.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: GeopragColors.green900,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recebimentos Pendentes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: GeopragColors.green900,
                          ),
                        ),
                        Text(
                          estoqueAtual.recebimentosPendentesDescricao,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: GeopragColors.green900,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
