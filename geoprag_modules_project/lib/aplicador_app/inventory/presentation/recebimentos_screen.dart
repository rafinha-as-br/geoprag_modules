import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
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
          return switch (state) {
            RecebimentosLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            RecebimentosError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Não foi possível carregar os recebimentos: $message',
                ),
              ),
            ),
            RecebimentosLoaded(:final recebimentos) => ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  'Selecione o produto para confirmar o recebimento:',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                for (final recebimento in recebimentos)
                  _RecebimentoCard(recebimento: recebimento),
              ],
            ),
          };
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
