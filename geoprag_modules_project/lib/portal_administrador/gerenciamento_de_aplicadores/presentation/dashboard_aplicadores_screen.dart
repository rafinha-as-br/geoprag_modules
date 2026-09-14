import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/geoprag_barra_acao_em_lote.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../../gerenciamento_de_administradores/presentation/widgets/geoprag_data_table.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciamento de Aplicadores')),
      body: SingleChildScrollView(
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
        // GEOPRAG-130: barra de ações do aplicador selecionado fica acima
        // da listagem (antes ficava abaixo, exigindo rolar a tela toda
        // para vê-la com muitos aplicadores). GeopragBarraAcaoEmLote
        // (GEOPRAG-141) mantém sempre a altura reservada e só alterna
        // visibilidade — nunca entra/sai da árvore condicionalmente —
        // porque selecionar a primeira linha faria a barra aparecer e
        // empurrar as demais linhas para baixo, quebrando a posição de
        // tela de um clique seguinte: exatamente o bug que a GEOPRAG-67
        // corrigiu ao mover a barra para baixo da tabela originalmente.
        GeopragBarraAcaoEmLote(
          quantidade: state.selecionados.length,
          processando: state.processandoAcaoEmMassa,
          onLimparSelecao: cubit.limparSelecao,
          acoes: [
            GeopragAcaoEmLoteBotao(
              icon: Icons.check_circle_outline,
              label: 'Ativar selecionados',
              onPressed: state.processandoAcaoEmMassa
                  ? null
                  : cubit.ativarSelecionados,
            ),
            GeopragAcaoEmLoteBotao(
              icon: Icons.block,
              label: 'Desativar selecionados',
              onPressed: state.processandoAcaoEmMassa
                  ? null
                  : cubit.desativarSelecionados,
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
      ],
    );
  }
}
