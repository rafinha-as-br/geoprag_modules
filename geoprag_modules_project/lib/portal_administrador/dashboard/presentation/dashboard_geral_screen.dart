import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../widgets/admin_scaffold.dart';
import 'dashboard_geral_cubit.dart';
import 'dashboard_geral_state.dart';
import 'resumo_geral_view_model.dart';

class DashboardGeralScreen extends StatelessWidget {
  const DashboardGeralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/dashboard',
      appBar: AppBar(title: const Text('Visão Geral')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<DashboardGeralCubit, DashboardGeralState>(
                builder: (context, state) {
                  return switch (state) {
                    DashboardGeralLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    DashboardGeralError(:final message) => Center(
                      child: Text(
                        'Não foi possível carregar o resumo geral: $message',
                      ),
                    ),
                    DashboardGeralLoaded(:final resumo) => _DashboardConteudo(
                      resumo: resumo,
                    ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardConteudo extends StatelessWidget {
  const _DashboardConteudo({required this.resumo});

  final ResumoGeralViewModel resumo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Row: KPIs
        Row(
          children: [
            _buildKpiCard(
              'Estoque Crítico',
              resumo.estoqueCriticoResumo,
              Icons.warning,
              GeopragColors.statusDenuncia,
            ),
            const SizedBox(width: 16),
            _buildKpiCard(
              'Aplicações Atrasadas',
              resumo.aplicacoesAtrasadasResumo,
              Icons.timer_off,
              GeopragColors.statusAtrasado,
            ),
            const SizedBox(width: 16),
            _buildKpiCard(
              'Denúncias Abertas',
              resumo.denunciasAbertasTotal,
              Icons.report,
              GeopragColors.statusDenuncia,
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Middle Row: Logs and Map
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Logs
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildLogPanel(
                      'Atualizações de Estoque',
                      resumo.atualizacoesEstoque,
                      Icons.inventory_2,
                    ),
                    const SizedBox(height: 16),
                    _buildLogPanel(
                      'Últimas Aplicações',
                      resumo.ultimasAplicacoes,
                      Icons.water_drop,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right Column: Map and Denúncias
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Visão Geográfica & Focos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: const Center(
                              child: Text(
                                '[Componente de Mapa Aqui]\nExibindo divisas de bairros e\nmarcações espaciais dos focos',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.blueGrey),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Focos Recentes',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        for (final foco in resumo.focosRecentes)
                          ListTile(
                            leading: const Icon(
                              Icons.bug_report,
                              color: GeopragColors.statusAtrasado,
                            ),
                            title: Text(foco.titulo),
                            subtitle: Text(foco.statusDescricao),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogPanel(String title, List<String> logs, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, color: GeopragColors.green900),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              logs[index],
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
