import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../core/aplicador_navigator.dart';
import 'tela_de_aplicacao_cubit.dart';
import 'tela_de_aplicacao_state.dart';

class TelaDeAplicacaoScreen extends StatelessWidget {
  const TelaDeAplicacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Execução da Aplicação')),
      body: BlocBuilder<TelaDeAplicacaoCubit, TelaDeAplicacaoState>(
        builder: (context, state) {
          return switch (state) {
            TelaDeAplicacaoLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            TelaDeAplicacaoError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Não foi possível carregar a aplicação: $message',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            TelaDeAplicacaoEmAndamento() => _TelaDeAplicacaoContent(
              estado: state,
            ),
          };
        },
      ),
    );
  }
}

class _TelaDeAplicacaoContent extends StatelessWidget {
  const _TelaDeAplicacaoContent({required this.estado});

  final TelaDeAplicacaoEmAndamento estado;

  @override
  Widget build(BuildContext context) {
    final ponto = estado.ponto;
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
                  ponto.dosagemFormatada,
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
            'Ponto ${ponto.nome} (${ponto.enderecoFormatado})',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Subponto ${estado.subpontosRegistrados} de '
            '${ponto.quantidadeDeSubpontos}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          if (estado.concluida) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GeopragColors.statusEmDia.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: GeopragColors.statusEmDia),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Aplicação registrada com sucesso! (Sincronizado)',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                AplicadorNavigatorScope.of(context).toPonto();
              },
              icon: const Icon(Icons.check),
              label: const Text('Voltar para Meus Pontos'),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: estado.registrando
                  ? null
                  : () {
                      context.read<TelaDeAplicacaoCubit>().registrarSubponto();
                    },
              icon: estado.registrando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text('Registrar Subponto'),
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
        ],
      ),
    );
  }
}
