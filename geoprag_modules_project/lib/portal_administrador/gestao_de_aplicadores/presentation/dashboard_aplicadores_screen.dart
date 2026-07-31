import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../../widgets/admin_scaffold.dart';
import '../../autenticacao/core/admin_navigator.dart';
import 'aplicador_view_model.dart';
import 'aplicadores_cubit.dart';
import 'aplicadores_state.dart';

class DashboardAplicadoresScreen extends StatelessWidget {
  const DashboardAplicadoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/aplicadores',
      appBar: AppBar(title: const Text('Gestão de Aplicadores')),
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
                        hintText: 'Buscar por nome, bairro ou status...',
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
                          AplicadoresLoaded(:final aplicadores) => Table(
                            border: TableBorder.all(color: Colors.grey[300]!),
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1),
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
                                      'Nome',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text(
                                      'Bairro/Trecho',
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
                              for (final aplicador in aplicadores)
                                _buildTableRow(context, aplicador),
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
    );
  }

  TableRow _buildTableRow(
    BuildContext context,
    AplicadorResumoViewModel aplicador,
  ) {
    final isAtivo = aplicador.status == 'ativo';
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(aplicador.nome)),
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
                  AdminNavigatorScope.of(
                    context,
                  ).toAplicadorDetalhes(aplicador.id);
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
