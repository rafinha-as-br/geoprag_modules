import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../widgets/sidebar_menu.dart';
// Acoplamento novo entre módulos irmãos (até então nenhum módulo de
// portal_administrador importava outro) — necessário porque atribuir um
// aplicador a um ponto exige a lista de Applicator do outro módulo.
import '../../applicators_management/core/applicator.dart';
import '../../applicators_management/data/mock_applicators.dart';
import '../data/mock_pontos_de_aplicacao.dart';
import 'status_ponto_de_aplicacao_badge.dart';
import 'view_models/ponto_de_aplicacao_detalhe_view_model.dart';

class VisualizacaoDePontoDeAplicacaoScreen extends StatelessWidget {
  const VisualizacaoDePontoDeAplicacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock: mesma convenção de VisualizacaoIndividualScreen — sem
    // argumentos de rota ainda, exibe um ponto de exemplo.
    final ponto = mockPontosDeAplicacao.first;
    final aplicadoresAtivos = mockApplicators
        .where((a) => a.status == 'ativo')
        .toList();
    final aplicadorAtual = ponto.aplicadorId == null
        ? null
        : _buscarAplicador(aplicadoresAtivos, ponto.aplicadorId!);
    final viewModel = PontoDeAplicacaoDetalheViewModel.fromEntity(
      ponto,
      nomeDoAplicador: aplicadorAtual?.name,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Ponto de Aplicação #${viewModel.id}')),
      body: Row(
        children: [
          const SidebarMenu(currentRoute: '/aplicacoes'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            viewModel.bairro,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          StatusPontoDeAplicacaoBadge(status: viewModel.status),
                          if (!viewModel.ativo) ...[
                            const SizedBox(width: 8),
                            const Chip(label: Text('Desativado')),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.edit),
                            label: const Text('Editar Ponto'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (viewModel.podeDesativar)
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.block),
                              label: const Text('Desativar Ponto'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: GeopragColors.statusAtrasado,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Dados do Ponto',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const Divider(),
                                ListTile(
                                  title: const Text('Coordenadas'),
                                  subtitle: Text(
                                    '${viewModel.lat.toStringAsFixed(4)}, ${viewModel.lng.toStringAsFixed(4)}',
                                  ),
                                ),
                                if (viewModel.dataAgendada != null)
                                  ListTile(
                                    title: const Text('Data Agendada'),
                                    subtitle: Text(
                                      _formatarData(viewModel.dataAgendada!),
                                    ),
                                  ),
                                if (viewModel.dataConcluida != null)
                                  ListTile(
                                    title: const Text('Data Concluída'),
                                    subtitle: Text(
                                      _formatarData(viewModel.dataConcluida!),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Aplicador Responsável',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String?>(
                                  initialValue: ponto.aplicadorId,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  items: [
                                    const DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text('Sem aplicador atribuído'),
                                    ),
                                    for (final aplicador in aplicadoresAtivos)
                                      DropdownMenuItem<String?>(
                                        value: aplicador.id,
                                        child: Text(aplicador.name),
                                      ),
                                  ],
                                  onChanged: viewModel.podeAtribuirAplicador
                                      ? (_) {}
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Registro Manual da Aplicação',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const Divider(),
                                const Text(
                                  'Fluxo de registro manual pelo portal ainda '
                                  'não detalhado com o Rafael.',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                // TODO(GEOPRAG-38): detalhar fluxo de
                                // registro manual junto ao Rafael.
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Applicator? _buscarAplicador(List<Applicator> aplicadores, String id) {
    for (final aplicador in aplicadores) {
      if (aplicador.id == id) return aplicador;
    }
    return null;
  }

  String _formatarData(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
}
