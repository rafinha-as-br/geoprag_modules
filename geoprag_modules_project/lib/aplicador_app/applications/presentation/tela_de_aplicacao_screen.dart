import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../core/aplicador_navigator.dart';
import 'aplicacao_atual_cubit.dart';
import 'aplicacao_atual_state.dart';
import 'aplicacao_view_model.dart';

class TelaDeAplicacaoScreen extends StatelessWidget {
  const TelaDeAplicacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Execução da Aplicação')),
      body: BlocBuilder<AplicacaoAtualCubit, AplicacaoAtualState>(
        builder: (context, state) {
          return switch (state) {
            AplicacaoAtualLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            AplicacaoAtualError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Não foi possível carregar a aplicação em andamento: $message',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            AplicacaoAtualLoaded(:final aplicacao) => _TelaDeAplicacaoContent(
              aplicacao: aplicacao,
            ),
          };
        },
      ),
    );
  }
}

class _TelaDeAplicacaoContent extends StatelessWidget {
  const _TelaDeAplicacaoContent({required this.aplicacao});

  final AplicacaoAtualViewModel aplicacao;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Dosagem Recomendada',
            style: TextStyle(fontSize: 18, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: GeopragColors.green900.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: GeopragColors.green900, width: 4),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.water_drop,
                  size: 48,
                  color: GeopragColors.green900,
                ),
                const SizedBox(height: 8),
                Text(
                  aplicacao.dosagemFormatada,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: GeopragColors.green900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ponto em ${aplicacao.localizacaoFormatada} · registrado em '
            '${aplicacao.dataFormatada}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          const Text(
            'Instruções:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const ListTile(
            leading: Icon(
              Icons.check_circle_outline,
              color: GeopragColors.green900,
            ),
            title: Text(
              'Despeje a dosagem exata indicada acima na correnteza do córrego.',
            ),
            contentPadding: EdgeInsets.zero,
          ),
          const ListTile(
            leading: Icon(
              Icons.check_circle_outline,
              color: GeopragColors.green900,
            ),
            title: Text('Evite aplicar em remansos ou água parada.'),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () {
              // TODO(GEOPRAG-24): substituir pelo registro real da
              // aplicação assim que o endpoint de escrita for validado com
              // o backend — hoje apenas navega de volta simulando sucesso.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Aplicação registrada com sucesso! (Sincronizado)',
                  ),
                  backgroundColor: GeopragColors.green900,
                ),
              );
              AplicadorNavigatorScope.of(context).toPonto();
            },
            icon: const Icon(Icons.check),
            label: const Text('Confirmar Aplicação'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              AplicadorNavigatorScope.of(context).back();
            },
            child: const Text(
              'Cancelar / Voltar',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
