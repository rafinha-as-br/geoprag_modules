import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/sidebar_menu.dart';
import '../../autenticacao/core/admin_navigator.dart';
import '../core/ponto_de_aplicacao.dart';
import 'pontos_de_aplicacao_cubit.dart';
import 'pontos_de_aplicacao_state.dart';
import 'status_ponto_de_aplicacao_badge.dart';
import 'view_models/ponto_de_aplicacao_resumo_view_model.dart';

class DashboardDeAplicacoesScreen extends StatelessWidget {
  const DashboardDeAplicacoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestão de Aplicações')),
      body: Row(
        children: [
          const SidebarMenu(currentRoute: '/aplicacoes'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Mapa de Aplicações',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selecione um bairro no mapa ou na legenda para ver as aplicações daquele bairro.',
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: BlocBuilder<PontosDeAplicacaoCubit, PontosDeAplicacaoState>(
                      builder: (context, state) {
                        return switch (state) {
                          PontosDeAplicacaoLoading() => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          PontosDeAplicacaoError(:final message) => Center(
                            child: Text(
                              'Não foi possível carregar as aplicações: $message',
                            ),
                          ),
                          PontosDeAplicacaoLoaded(:final pontos) =>
                            _DashboardConteudo(pontos: pontos),
                        };
                      },
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
  final List<PontoDeAplicacaoResumoViewModel> pontos;

  const _DashboardConteudo({required this.pontos});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Mapa
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Text(
                    '[Mapa Interativo de Gaspar]\nBairros clicáveis',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.green, fontSize: 18),
                  ),
                ),
                for (final (index, ponto) in pontos.indexed)
                  Positioned(
                    top: 60.0 + (index * 70 % 260),
                    left: 40.0 + (index * 140 % 420),
                    child: InkWell(
                      onTap: () => AdminNavigatorScope.of(
                        context,
                      ).toAplicacaoBairro(ponto.bairro),
                      child: Column(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: ponto.status.color,
                            size: 48,
                          ),
                          Text(
                            ponto.bairro,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Legenda
        Expanded(
          flex: 1,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Legenda',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  for (final status in StatusPontoDeAplicacao.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: StatusPontoDeAplicacaoBadge(status: status),
                    ),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Bairros',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: [
                        for (final ponto in pontos)
                          ListTile(
                            leading: Icon(
                              Icons.location_on,
                              color: ponto.status.color,
                            ),
                            title: Text(ponto.bairro),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                            ),
                            onTap: () => AdminNavigatorScope.of(
                              context,
                            ).toAplicacaoBairro(ponto.bairro),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
