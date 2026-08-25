import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/base_card_list_screen.dart';
import '../../core/aplicador_navigator.dart';
import 'recebimento_view_model.dart';
import 'recebimentos_cubit.dart';
import 'recebimentos_state.dart';

class RecebimentosScreen extends StatelessWidget {
  const RecebimentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recebimentos Pendentes')),
      body: BlocBuilder<RecebimentosCubit, RecebimentosState>(
        builder: (context, state) {
          return Column(
            children: [
              if (state is RecebimentosLoaded)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    'Selecione o produto para confirmar o recebimento:',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              Expanded(
                child: BaseCardListScreen<RecebimentoResumoViewModel>(
                  isLoading: state is RecebimentosLoading,
                  errorMessage: state is RecebimentosError
                      ? 'Não foi possível carregar os recebimentos: ${state.message}'
                      : null,
                  items: state is RecebimentosLoaded
                      ? state.recebimentos
                      : null,
                  itemBuilder: (context, recebimento) =>
                      _RecebimentoCard(recebimento: recebimento),
                  separatorBuilder: (context, index) => const SizedBox(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  emptyStateMessage: 'Nenhum recebimento pendente.',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RecebimentoCard extends StatelessWidget {
  const _RecebimentoCard({required this.recebimento});

  final RecebimentoResumoViewModel recebimento;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: GeopragColors.neutralLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.science_outlined,
            color: GeopragColors.green900,
          ),
        ),
        title: Text(
          recebimento.tituloProduto,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${recebimento.enviadoPorDescricao}\n${recebimento.dataDescricao}',
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          AplicadorNavigatorScope.of(context).toRecebimentoConfirmar();
        },
      ),
    );
  }
}
