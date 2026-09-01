import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../../gerenciamento_de_administradores/presentation/widgets/geoprag_data_table.dart';
import '../../widgets/admin_scaffold.dart';
import '../../autenticacao/core/admin_navigator.dart';
import 'aplicador_view_model.dart';
import 'aplicadores_cubit.dart';
import 'aplicadores_state.dart';

class DashboardAplicadoresScreen extends StatefulWidget {
  const DashboardAplicadoresScreen({super.key});

  @override
  State<DashboardAplicadoresScreen> createState() =>
      _DashboardAplicadoresScreenState();
}

class _DashboardAplicadoresScreenState
    extends State<DashboardAplicadoresScreen> {
  final _buscaController = TextEditingController();
  String _busca = '';

  @override
  void initState() {
    super.initState();
    _buscaController.addListener(() {
      setState(() => _busca = _buscaController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  List<AplicadorResumoViewModel> _filtrarPorBusca(
    List<AplicadorResumoViewModel> lista,
  ) {
    if (_busca.isEmpty) return lista;
    return lista
        .where(
          (a) =>
              a.nome.toLowerCase().contains(_busca) ||
              (a.ativo ? 'ativo' : 'desativado').contains(_busca),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/aplicadores',
      appBar: AppBar(title: const Text('Gerenciamento de Aplicadores')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Voluntários Cadastrados',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    AdminNavigatorScope.of(context).toCriarAplicador();
                  },
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
                      controller: _buscaController,
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
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          AplicadoresError(:final message) => Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Não foi possível carregar os aplicadores: $message',
                            ),
                          ),
                          AplicadoresLoaded() => _DashboardConteudo(
                            state: state,
                            aplicadoresFiltrados: _filtrarPorBusca(
                              state.aplicadoresFiltrados,
                            ),
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
    );
  }
}

class _DashboardConteudo extends StatelessWidget {
  const _DashboardConteudo({
    required this.state,
    required this.aplicadoresFiltrados,
  });

  final AplicadoresLoaded state;
  final List<AplicadorResumoViewModel> aplicadoresFiltrados;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AplicadoresCubit>();
    if (aplicadoresFiltrados.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Nenhum aplicador encontrado.'),
      );
    }
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
        const SizedBox(height: 16),
        // GEOPRAG-67 (review Rafinha, PR #14): reusa o componente
        // GeopragDataTable extraído na GEOPRAG-36, em vez de um Table
        // duplicado localmente. onRowTap substitui a antiga coluna de
        // "Ações" — clicar em qualquer ponto da linha (fora da célula de
        // seleção) abre o detalhe do Aplicador.
        GeopragDataTable<AplicadorResumoViewModel>(
          items: aplicadoresFiltrados,
          onRowTap: (context, aplicador) =>
              AdminNavigatorScope.of(context).toAplicadorDetalhes(aplicador.id),
          columns: [
            GeopragDataColumn(
              label: 'Selecionar',
              width: const FixedColumnWidth(48),
              headerBuilder: (context) => Checkbox(
                value: todosVisiveisSelecionados,
                onChanged: state.processandoAcaoEmMassa
                    ? null
                    : (_) => cubit.alternarSelecaoDeTodosVisiveis(),
              ),
              cellBuilder: (context, aplicador) => Checkbox(
                value: state.selecionados.contains(aplicador.id),
                onChanged: state.processandoAcaoEmMassa
                    ? null
                    : (_) => cubit.alternarSelecao(aplicador.id),
              ),
            ),
            GeopragDataColumn(
              label: 'Nome',
              width: const FlexColumnWidth(2),
              cellBuilder: (context, aplicador) => Text(aplicador.nome),
            ),
            GeopragDataColumn(
              // GEOPRAG-69: renomeado de "Bairro/Trecho" — esta coluna
              // sempre exibiu o bairro de residência do Aplicador
              // (Usuario.bairro, GEOPRAG-70), nunca um "ponto de
              // aplicação"/"subponto" (conceito não relacionado, sem
              // vínculo com Aplicador nesta tela — ver GEOPRAG-71).
              label: 'Bairro',
              width: const FlexColumnWidth(2),
              cellBuilder: (context, aplicador) => Text(aplicador.bairro),
            ),
            GeopragDataColumn(
              label: 'Status',
              width: const FlexColumnWidth(1),
              cellBuilder: (context, aplicador) => GeopragStatusBadge(
                status: aplicador.ativo
                    ? GeopragStatus.emDia
                    : GeopragStatus.atrasado,
                label: aplicador.ativo ? 'Ativo' : 'Desativado',
                dense: true,
              ),
            ),
          ],
        ),
        if (state.selecionados.isNotEmpty) ...[
          const SizedBox(height: 12),
          _BarraAcaoEmMassa(state: state, cubit: cubit),
        ],
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
    // GEOPRAG-67 (review Rafinha, PR #14): fundo verde escuro (M3
    // primaryContainer) com texto no estilo padrão (preto) ficava
    // ilegível — o texto agora usa onPrimaryContainer, o par de contraste
    // correto definido em GeopragTheme.
    final onPrimaryContainer = Theme.of(context).colorScheme.onPrimaryContainer;

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
          Text(
            '$quantidade selecionado(s)',
            style: TextStyle(color: onPrimaryContainer),
          ),
          OutlinedButton.icon(
            onPressed: processando ? null : cubit.ativarSelecionados,
            icon: Icon(Icons.check_circle_outline, color: onPrimaryContainer),
            label: Text(
              'Ativar selecionados',
              style: TextStyle(color: onPrimaryContainer),
            ),
            style: OutlinedButton.styleFrom(side: BorderSide(color: onPrimaryContainer)),
          ),
          OutlinedButton.icon(
            onPressed: processando ? null : cubit.desativarSelecionados,
            icon: Icon(Icons.block, color: onPrimaryContainer),
            label: Text(
              'Desativar selecionados',
              style: TextStyle(color: onPrimaryContainer),
            ),
            style: OutlinedButton.styleFrom(side: BorderSide(color: onPrimaryContainer)),
          ),
          TextButton(
            onPressed: processando ? null : cubit.limparSelecao,
            child: Text(
              'Limpar seleção',
              style: TextStyle(color: onPrimaryContainer),
            ),
          ),
          if (processando)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: onPrimaryContainer,
              ),
            ),
        ],
      ),
    );
  }
}
