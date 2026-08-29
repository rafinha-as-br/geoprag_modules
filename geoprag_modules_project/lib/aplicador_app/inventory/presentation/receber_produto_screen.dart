import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/base_interstitial_screen.dart';
import '../../core/aplicador_navigator.dart';
import 'recebimento_confirmacao_cubit.dart';
import 'recebimento_confirmacao_state.dart';
import 'recebimento_view_model.dart';

/// Tela de confirmação de recebimento de insumo (GEOPRAG-106) — sem campos
/// de formulário (só exibe os dados do recebimento e confirma), então usa
/// [BaseInterstitialScreen] (arquétipo ícone → título → corpo → botão
/// primário → botão secundário) em vez de `BaseFormScreen`, que pressupõe
/// campos e validação.
class ReceberProdutoScreen extends StatelessWidget {
  const ReceberProdutoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Recebimento')),
      body:
          BlocBuilder<RecebimentoConfirmacaoCubit, RecebimentoConfirmacaoState>(
            builder: (context, state) {
              return switch (state) {
                RecebimentoConfirmacaoLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                RecebimentoConfirmacaoError(:final message) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Não foi possível carregar o recebimento: $message',
                    ),
                  ),
                ),
                RecebimentoConfirmacaoLoaded(:final recebimento) =>
                  _ReceberProdutoConteudo(recebimento: recebimento),
              };
            },
          ),
    );
  }
}

class _ReceberProdutoConteudo extends StatelessWidget {
  const _ReceberProdutoConteudo({required this.recebimento});

  final RecebimentoDetalheViewModel recebimento;

  @override
  Widget build(BuildContext context) {
    return BaseInterstitialScreen(
      icon: Icons.inventory_2,
      iconColor: GeopragColors.green900,
      title: recebimento.tituloProduto,
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalhes da Entrega',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Agente Entregador:', style: TextStyle(color: Colors.grey)),
            Text(
              recebimento.agenteEntregadorDescricao,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Data de Despacho:', style: TextStyle(color: Colors.grey)),
            Text(
              recebimento.dataDespachoDescricao,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Quantidade / Volume:',
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              recebimento.quantidadeDescricao,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      primaryLabel: 'Confirmar Recebimento',
      onPrimary: () async {
        await context.read<RecebimentoConfirmacaoCubit>().confirmar();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Recebimento confirmado! Estoque atualizado.'),
            backgroundColor: GeopragColors.green900,
          ),
        );
        AplicadorNavigatorScope.of(context).toInventario();
      },
      secondaryLabel: 'Cancelar / Voltar',
      onSecondary: () => AplicadorNavigatorScope.of(context).back(),
    );
  }
}
