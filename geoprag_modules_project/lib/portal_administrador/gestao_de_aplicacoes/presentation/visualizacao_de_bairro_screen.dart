import 'package:flutter/material.dart';

import '../../widgets/sidebar_menu.dart';
import '../../core/admin_navigator.dart';
import '../data/mock_pontos_de_aplicacao.dart';
import 'status_ponto_de_aplicacao_badge.dart';
import 'view_models/ponto_de_aplicacao_resumo_view_model.dart';

class VisualizacaoDeBairroScreen extends StatelessWidget {
  const VisualizacaoDeBairroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock: exibe o bairro do primeiro ponto ativo. Nenhuma tela deste app
    // ainda passa argumentos de rota (ver AdminNavigator) — mesma
    // convenção usada em DetalheDoBairroScreen/VisualizacaoIndividualScreen.
    final bairro = mockPontosDeAplicacao.first.bairro;
    final pontos = mockPontosDeAplicacao
        .where((p) => p.ativo && p.bairro == bairro)
        .map(PontoDeAplicacaoResumoViewModel.fromEntity)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Aplicações em $bairro')),
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
                      Text(
                        bairro,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => AdminNavigatorScope.of(
                          context,
                        ).toAplicacaoCriarPonto(),
                        icon: const Icon(Icons.add_location_alt),
                        label: const Text('Novo Ponto'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mapa do bairro
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Center(
                              child: Text(
                                '[Mapa de $bairro]\n${pontos.length} ponto(s) de aplicação',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Lista de aplicações
                        Expanded(
                          flex: 3,
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
                                    'Pontos de Aplicação',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: ListView.separated(
                                      itemCount: pontos.length,
                                      separatorBuilder: (_, _) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final ponto = pontos[index];
                                        return ListTile(
                                          title: Text('Ponto #${ponto.id}'),
                                          subtitle: Text(
                                            '${ponto.lat.toStringAsFixed(4)}, ${ponto.lng.toStringAsFixed(4)}',
                                          ),
                                          trailing: StatusPontoDeAplicacaoBadge(
                                            status: ponto.status,
                                            dense: true,
                                          ),
                                          onTap: () => AdminNavigatorScope.of(
                                            context,
                                          ).toAplicacaoDetalhes(),
                                        );
                                      },
                                    ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
