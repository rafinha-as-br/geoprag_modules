import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../../widgets/sidebar_menu.dart';
import '../../core/admin_navigator.dart';
import 'produto_view_model.dart';
import 'produtos_cubit.dart';
import 'produtos_state.dart';

class DashboardEstoqueScreen extends StatelessWidget {
  const DashboardEstoqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controle de Estoque e Compras')),
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
                        'Inventário Geral',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              AdminNavigatorScope.of(
                                context,
                              ).toEstoqueFormula();
                            },
                            icon: const Icon(Icons.calculate),
                            label: const Text('Fórmula de Dosagem'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              AdminNavigatorScope.of(
                                context,
                              ).toEstoqueLicitacao();
                            },
                            icon: const Icon(Icons.description),
                            label: const Text('Nova Licitação'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              AdminNavigatorScope.of(
                                context,
                              ).toEstoqueProduto();
                            },
                            icon: const Icon(Icons.add_box),
                            label: const Text('Registrar Entrada'),
                          ),
                        ],
                      ),
                    ],
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
                        child: Column(
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                hintText:
                                    'Buscar produto por lote ou licitação...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            BlocBuilder<ProdutosCubit, ProdutosState>(
                              builder: (context, state) {
                                return switch (state) {
                                  ProdutosLoading() => const Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  ProdutosError(:final message) => Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Text(
                                      'Não foi possível carregar os produtos: $message',
                                    ),
                                  ),
                                  ProdutosLoaded(:final produtos) => Table(
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
                                              'Produto / Lote',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Text(
                                              'Licitação',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Text(
                                              'Estoque Atual',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Text(
                                              'Status',
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
                                      for (final produto in produtos)
                                        _buildTableRow(context, produto),
                                    ],
                                  ),
                                };
                              },
                            ),
                          ],
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

  TableRow _buildTableRow(
    BuildContext context,
    ProdutoResumoViewModel produto,
  ) {
    final statusExibicao = _statusExibicao(produto);
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('${produto.nome} - Lote ${produto.lote}'),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(produto.licitacao),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('${produto.quantidade} ${produto.unidadeMedida}'),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: GeopragStatusBadge(
            status: statusExibicao.status,
            label: statusExibicao.label,
            dense: true,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: IconButton(
            icon: const Icon(Icons.visibility, color: Colors.blue),
            onPressed: () {
              AdminNavigatorScope.of(context).toEstoqueVisualizacao();
            },
          ),
        ),
      ],
    );
  }

  /// Deriva o status visual (cor + rótulo do badge) exibido na listagem a
  /// partir da quantidade em estoque e da validade do lote.
  ///
  /// TODO(GEOPRAG-24): regra de "próximo do vencimento" (30 dias) é uma
  /// aproximação de UI enquanto não há parâmetro configurável vindo do
  /// backend.
  ({GeopragStatus status, String label}) _statusExibicao(
    ProdutoResumoViewModel produto,
  ) {
    if (produto.quantidade <= 0) {
      return (status: GeopragStatus.atrasado, label: 'Esgotado');
    }
    final agora = DateTime.now();
    if (produto.dataValidade.isBefore(agora)) {
      return (status: GeopragStatus.atrasado, label: 'Vencido');
    }
    if (produto.dataValidade.difference(agora).inDays <= 30) {
      return (status: GeopragStatus.denuncia, label: 'Perto do Venc.');
    }
    return (status: GeopragStatus.emDia, label: 'Em estoque');
  }
}
