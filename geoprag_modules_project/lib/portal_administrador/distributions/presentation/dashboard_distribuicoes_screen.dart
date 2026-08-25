import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/base_card_list_screen.dart';
import '../../widgets/admin_scaffold.dart';
import '../../autenticacao/core/admin_navigator.dart';
import 'distribuicao_view_model.dart';
import 'distribuicoes_cubit.dart';
import 'distribuicoes_state.dart';

class DashboardDistribuicoesScreen extends StatelessWidget {
  const DashboardDistribuicoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/distribuicoes',
      appBar: AppBar(title: const Text('Gestão de Distribuições (Saídas)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Histórico de Saídas',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    AdminNavigatorScope.of(context).toDistribuicaoCadastro();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nova Saída'),
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
                  child: BlocBuilder<DistribuicoesCubit, DistribuicoesState>(
                    builder: (context, state) {
                      return BaseCardListScreen<DistribuicaoResumoViewModel>(
                        isLoading: state is DistribuicoesLoading,
                        errorMessage: state is DistribuicoesError
                            ? 'Não foi possível carregar as distribuições: ${state.message}'
                            : null,
                        items: state is DistribuicoesLoaded
                            ? state.distribuicoes
                            : null,
                        itemBuilder: (context, distribuicao) =>
                            _buildListTile(context, distribuicao),
                        emptyStateMessage: 'Nenhuma distribuição encontrada.',
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    DistribuicaoResumoViewModel distribuicao,
  ) {
    final status = _statusConfirmacaoParaGeopragStatus(
      distribuicao.statusConfirmacao,
    );
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: status.color,
        child: const Icon(Icons.local_shipping, color: Colors.white),
      ),
      title: Text(
        '${distribuicao.produtoNome} - ${distribuicao.quantidade} ${distribuicao.unidade}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Para: ${distribuicao.responsavel} (${distribuicao.bairroResponsavel})\n'
        'Data: ${distribuicao.dataEntrega}',
      ),
      isThreeLine: true,
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        AdminNavigatorScope.of(
          context,
        ).toDistribuicaoVisualizacao(distribuicao.id);
      },
    );
  }
}

GeopragStatus _statusConfirmacaoParaGeopragStatus(String statusConfirmacao) {
  switch (statusConfirmacao) {
    case 'confirmado':
      return GeopragStatus.emDia;
    case 'recusado':
      return GeopragStatus.atrasado;
    case 'aguardando_aceite':
    default:
      return GeopragStatus.denuncia;
  }
}
