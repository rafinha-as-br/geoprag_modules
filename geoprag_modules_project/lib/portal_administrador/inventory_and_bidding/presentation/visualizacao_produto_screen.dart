import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/base_detail_screen.dart';
import '../core/movimentacao_produto.dart';
import 'produto_detalhe_cubit.dart';
import 'produto_detalhe_state.dart';
import 'produto_view_model.dart';

class VisualizacaoProdutoScreen extends StatelessWidget {
  const VisualizacaoProdutoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Produto no Estoque')),
      body: BlocBuilder<ProdutoDetalheCubit, ProdutoDetalheState>(
        builder: (context, state) {
          return BaseDetailScreen(
            variant: BaseDetailScreenVariant.cartaoCentralizado,
            title: switch (state) {
              ProdutoDetalheLoaded(:final produto) =>
                '${produto.nome} - Lote ${produto.lote}',
              _ => '',
            },
            isLoading: state is ProdutoDetalheLoading,
            errorMessage: switch (state) {
              ProdutoDetalheError(:final message) =>
                'Não foi possível carregar o produto: $message',
              _ => null,
            },
            actions: [
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {},
              ),
              IconButton(
                tooltip: 'Excluir',
                icon: const Icon(
                  Icons.delete,
                  color: GeopragColors.statusAtrasado,
                ),
                onPressed: () {},
              ),
            ],
            contentBuilder: (context) => switch (state) {
              ProdutoDetalheLoaded(:final produto) =>
                _ProdutoDetalheContent(produto: produto),
              _ => const SizedBox.shrink(),
            },
          );
        },
      ),
    );
  }
}

class _ProdutoDetalheContent extends StatelessWidget {
  const _ProdutoDetalheContent({required this.produto});

  final ProdutoDetalhadoViewModel produto;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          title: const Text(
            'Licitação Vinculada',
            style: TextStyle(color: Colors.grey),
          ),
          subtitle: Text(
            produto.licitacao,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ListTile(
          title: const Text('Fornecedor', style: TextStyle(color: Colors.grey)),
          subtitle: Text(
            produto.fornecedor,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ListTile(
          title: const Text(
            'Quantidade Original',
            style: TextStyle(color: Colors.grey),
          ),
          subtitle: Text(
            '${produto.quantidadeOriginal} ${produto.unidadeMedida}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ListTile(
          title: const Text(
            'Estoque Atual Disponível',
            style: TextStyle(color: Colors.grey),
          ),
          subtitle: Text(
            '${produto.quantidade} ${produto.unidadeMedida}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: GeopragColors.statusEmDia,
            ),
          ),
        ),
        ListTile(
          title: const Text('Validade', style: TextStyle(color: Colors.grey)),
          subtitle: Text(
            _formatarData(produto.dataValidade),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Nota: Este produto permite edição apenas em campos não-críticos e não pode ser excluído.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
        const Text(
          'Histórico de Movimentações',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const Divider(),
        if (produto.movimentacoes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Nenhuma movimentação registrada para este produto.',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          for (final movimentacao in produto.movimentacoes)
            ListTile(
              leading: Icon(
                movimentacao.tipo == MovimentacaoProdutoTipo.entrada
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: movimentacao.tipo == MovimentacaoProdutoTipo.entrada
                    ? GeopragColors.statusEmDia
                    : GeopragColors.statusAtrasado,
              ),
              title: Text(movimentacao.titulo),
              subtitle: Text(movimentacao.subtitulo),
              trailing: Text(movimentacao.valor),
            ),
      ],
    );
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }
}
