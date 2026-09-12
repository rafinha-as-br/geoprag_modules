import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/base_detail_screen.dart';
import 'distribuicao_detalhe_cubit.dart';
import 'distribuicao_detalhe_state.dart';
import 'distribuicao_view_model.dart';

class VisualizacaoSaidaScreen extends StatelessWidget {
  const VisualizacaoSaidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ficha de Distribuição')),
      body:
          BlocBuilder<DistribuicaoDetalheCubit, DistribuicaoDetalheState>(
            builder: (context, state) {
              return BaseDetailScreen(
                variant: BaseDetailScreenVariant.cartaoCentralizado,
                title: 'Comprovante de Saída',
                isLoading: state is DistribuicaoDetalheLoading,
                errorMessage: switch (state) {
                  DistribuicaoDetalheError(:final message) =>
                    'Não foi possível carregar a distribuição: $message',
                  _ => null,
                },
                actions: [
                  IconButton(
                    tooltip: 'Imprimir',
                    icon: const Icon(Icons.print),
                    onPressed: () {},
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar Registro'),
                  ),
                ],
                contentBuilder: (context) => switch (state) {
                  DistribuicaoDetalheLoaded(:final distribuicao) =>
                    _DistribuicaoDetalheContent(distribuicao: distribuicao),
                  _ => const SizedBox.shrink(),
                },
              );
            },
          ),
    );
  }
}

class _DistribuicaoDetalheContent extends StatelessWidget {
  const _DistribuicaoDetalheContent({required this.distribuicao});

  final DistribuicaoDetalhadaViewModel distribuicao;

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusConfirmacaoInfo(distribuicao.statusConfirmacao);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          title: const Text(
            'Data da Entrega',
            style: TextStyle(color: Colors.grey),
          ),
          subtitle: Text(
            distribuicao.dataEntrega,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ListTile(
          title: const Text(
            'Produto / Lote',
            style: TextStyle(color: Colors.grey),
          ),
          subtitle: Text(
            distribuicao.produtoNome,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ListTile(
          title: const Text('Quantidade', style: TextStyle(color: Colors.grey)),
          subtitle: Text(
            '${distribuicao.quantidade} ${distribuicao.unidade}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ListTile(
          title: const Text(
            'Responsável pelo Recebimento',
            style: TextStyle(color: Colors.grey),
          ),
          subtitle: Text(
            '${distribuicao.responsavel} (${distribuicao.bairroResponsavel})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ListTile(
          title: const Text(
            'Status de Confirmação',
            style: TextStyle(color: Colors.grey),
          ),
          subtitle: Text(
            statusInfo.label,
            style: TextStyle(
              color: statusInfo.color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Nota: Este documento de saída permite edição apenas em campos não-críticos e não pode ser excluído.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}

class _StatusConfirmacaoInfo {
  final String label;
  final Color color;
  const _StatusConfirmacaoInfo(this.label, this.color);
}

_StatusConfirmacaoInfo _statusConfirmacaoInfo(String statusConfirmacao) {
  switch (statusConfirmacao) {
    case 'confirmado':
      return const _StatusConfirmacaoInfo(
        'Confirmado no app mobile',
        GeopragColors.statusEmDia,
      );
    case 'recusado':
      return const _StatusConfirmacaoInfo(
        'Recusado no app mobile',
        GeopragColors.statusAtrasado,
      );
    case 'aguardando_aceite':
    default:
      return const _StatusConfirmacaoInfo(
        'Aguardando aceite no app mobile',
        GeopragColors.statusDenuncia,
      );
  }
}
