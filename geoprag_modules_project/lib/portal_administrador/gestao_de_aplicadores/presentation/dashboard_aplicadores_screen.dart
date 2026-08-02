import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../../widgets/sidebar_menu.dart';
import '../../autenticacao/core/admin_navigator.dart';
import 'aplicador_view_model.dart';
import 'aplicadores_cubit.dart';
import 'aplicadores_state.dart';

class DashboardAplicadoresScreen extends StatelessWidget {
  const DashboardAplicadoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestão de Aplicadores')),
      body: Row(
        children: [
          const SidebarMenu(currentRoute: '/aplicadores'),
          // Main Content
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
                        'Voluntários Cadastrados',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                        label: const Text('Novo Aplicador'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
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
                              hintText: 'Buscar por nome ou status...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          BlocBuilder<AplicadoresCubit, AplicadoresState>(
                            builder: (context, state) {
                              return switch (state) {
                                AplicadoresLoading() => const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                AplicadoresError(:final message) => Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    'Não foi possível carregar os aplicadores: $message',
                                  ),
                                ),
                                AplicadoresLoaded() => _DashboardConteudo(
                                  state: state,
                                ),
                              };
                            },
                          ),
                        ],
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
}

class _DashboardConteudo extends StatelessWidget {
  const _DashboardConteudo({required this.state});

  final AplicadoresLoaded state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AplicadoresCubit>();
    final aplicadoresFiltrados = state.aplicadoresFiltrados;
    final idsVisiveis = aplicadoresFiltrados.map((a) => a.id).toSet();
    final todosVisiveisSelecionados =
        idsVisiveis.isNotEmpty && idsVisiveis.every(state.selecionados.contains);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Todos'),
              selected: state.filtro == FiltroStatusAplicador.todos,
              onSelected: (_) =>
                  cubit.alterarFiltro(FiltroStatusAplicador.todos),
            ),
            ChoiceChip(
              label: const Text('Ativos'),
              selected: state.filtro == FiltroStatusAplicador.ativos,
              onSelected: (_) =>
                  cubit.alterarFiltro(FiltroStatusAplicador.ativos),
            ),
            ChoiceChip(
              label: const Text('Desativados'),
              selected: state.filtro == FiltroStatusAplicador.desativados,
              onSelected: (_) =>
                  cubit.alterarFiltro(FiltroStatusAplicador.desativados),
            ),
          ],
        ),
        if (state.selecionados.isNotEmpty) ...[
          const SizedBox(height: 12),
          _BarraAcaoEmMassa(state: state, cubit: cubit),
        ],
        const SizedBox(height: 16),
        Table(
          border: TableBorder.all(color: Colors.grey[300]!),
          columnWidths: const {
            0: FixedColumnWidth(48),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[100]),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Checkbox(
                    value: todosVisiveisSelecionados,
                    onChanged: state.processandoAcaoEmMassa
                        ? null
                        : (_) => cubit.alternarSelecaoDeTodosVisiveis(),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Nome',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Bairro/Trecho',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Ações',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            for (final aplicador in aplicadoresFiltrados)
              _buildTableRow(context, cubit, state, aplicador),
          ],
        ),
      ],
    );
  }

  TableRow _buildTableRow(
    BuildContext context,
    AplicadoresCubit cubit,
    AplicadoresLoaded state,
    AplicadorResumoViewModel aplicador,
  ) {
    final isAtivo = aplicador.status == 'ativo';
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Checkbox(
            value: state.selecionados.contains(aplicador.id),
            onChanged: state.processandoAcaoEmMassa
                ? null
                : (_) => cubit.alternarSelecao(aplicador.id),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(aplicador.nome),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(aplicador.bairro),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: GeopragStatusBadge(
            status: isAtivo ? GeopragStatus.emDia : GeopragStatus.atrasado,
            label: isAtivo ? 'Ativo' : 'Desativado',
            dense: true,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.blue),
                onPressed: () {
                  AdminNavigatorScope.of(context).toAplicadorDetalhes();
                },
                tooltip: 'Visualizar',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BarraAcaoEmMassa extends StatelessWidget {
  const _BarraAcaoEmMassa({required this.state, required this.cubit});

  final AplicadoresLoaded state;
  final AplicadoresCubit cubit;

  @override
  Widget build(BuildContext context) {
    final quantidade = state.selecionados.length;
    final processando = state.processandoAcaoEmMassa;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          Text('$quantidade selecionado(s)'),
          OutlinedButton.icon(
            onPressed: processando ? null : cubit.ativarSelecionados,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Ativar selecionados'),
          ),
          OutlinedButton.icon(
            onPressed: processando ? null : cubit.desativarSelecionados,
            icon: const Icon(Icons.block),
            label: const Text('Desativar selecionados'),
          ),
          TextButton(
            onPressed: processando ? null : cubit.limparSelecao,
            child: const Text('Limpar seleção'),
          ),
          if (processando)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}
