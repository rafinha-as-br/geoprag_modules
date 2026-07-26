import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../../widgets/sidebar_menu.dart';
import '../../core/admin_navigator.dart';
import 'denuncia_view_model.dart';
import 'denuncias_cubit.dart';
import 'denuncias_state.dart';

/// Visão de triagem: panorama rápido de todas as denúncias registradas,
/// para a equipe decidir o que priorizar. Para a listagem completa e
/// pesquisável, ver `ListagemDeDenunciasScreen`.
class DashboardDenunciasAdminScreen extends StatelessWidget {
  const DashboardDenunciasAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestão de Denúncias')),
      body: Row(
        children: [
          const SidebarMenu(currentRoute: '/denuncias_admin'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Triagem e Acompanhamento de Focos',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: 'Todas',
                                  decoration: const InputDecoration(
                                    labelText: 'Filtrar por Status',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Todas',
                                      child: Text('Todas as Denúncias'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Recebida',
                                      child: Text('Recebida'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Equipe a Investigar',
                                      child: Text('Equipe a Investigar'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Em Combate',
                                      child: Text('Em Combate'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Resolvido',
                                      child: Text('Resolvido'),
                                    ),
                                  ],
                                  onChanged: (v) {},
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: 'Todos',
                                  decoration: const InputDecoration(
                                    labelText: 'Nível de Infestação',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Todos',
                                      child: Text('Todos os Níveis'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Alto',
                                      child: Text('Alto (Prioridade)'),
                                    ),
                                  ],
                                  onChanged: (v) {},
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<DenunciasCubit, DenunciasState>(
                            builder: (context, state) {
                              return switch (state) {
                                DenunciasLoading() => const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                DenunciasError(:final message) => Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    'Não foi possível carregar as denúncias: $message',
                                  ),
                                ),
                                DenunciasLoaded(:final denuncias) => Table(
                                  border: TableBorder.all(
                                    color: Colors.grey[300]!,
                                  ),
                                  columnWidths: const {
                                    0: FlexColumnWidth(1),
                                    1: FlexColumnWidth(2),
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
                                            'Data',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Text(
                                            'Descrição do Local',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Text(
                                            'Nível',
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
                                    for (final denuncia in denuncias)
                                      _buildTableRow(context, denuncia),
                                  ],
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

  TableRow _buildTableRow(
    BuildContext context,
    DenunciaResumoViewModel denuncia,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(denuncia.dataFormatada),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(denuncia.descricao),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            denuncia.nivelInfestacao,
            style: TextStyle(
              color: _corNivel(denuncia.nivelInfestacao),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: GeopragStatusBadge(
            status: _statusParaBadge(denuncia.status),
            label: denuncia.status,
            dense: true,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: IconButton(
            icon: const Icon(Icons.visibility, color: Colors.blue),
            onPressed: () {
              AdminNavigatorScope.of(context).toDenunciaAdminDetalhes();
            },
            tooltip: 'Analisar e Tratar',
          ),
        ),
      ],
    );
  }
}

Color _corNivel(String nivel) {
  switch (nivel) {
    case 'Alto':
      return GeopragColors.statusAtrasado;
    case 'Médio':
      return GeopragColors.statusDenuncia;
    default:
      return GeopragColors.statusEmDia;
  }
}

GeopragStatus _statusParaBadge(String status) =>
    status == 'Resolvido' ? GeopragStatus.emDia : GeopragStatus.denuncia;
