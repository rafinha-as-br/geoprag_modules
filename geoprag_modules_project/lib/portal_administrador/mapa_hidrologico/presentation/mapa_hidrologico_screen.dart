import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/geoprag_map_placeholder.dart';
import '../../widgets/admin_scaffold.dart';
import '../../autenticacao/core/admin_navigator.dart';
import 'bairro_view_model.dart';
import 'bairros_cubit.dart';
import 'bairros_state.dart';

/// Posições fixas (apenas de layout, não são dado de domínio) usadas para
/// distribuir os pins dos bairros sobre o placeholder de mapa interativo.
/// Quando o mapa real (com coordenadas geográficas) for integrado, esta
/// lista deixa de ser necessária.
const List<Offset> _posicoesPinsMock = [
  Offset(200, 100),
  Offset(350, 200),
  Offset(120, 260),
  Offset(420, 90),
  Offset(280, 320),
];

class MapaHidrologicoScreen extends StatelessWidget {
  const MapaHidrologicoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/mapa',
      appBar: AppBar(title: const Text('Mapa Hidrológico e Monitoramento')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Mapa do Município',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecione um bairro no mapa para visualizar a situação dos córregos e aplicações.',
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<BairrosCubit, BairrosState>(
                builder: (context, state) {
                  return switch (state) {
                    BairrosLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    BairrosError(:final message) => Center(
                      child: Text(
                        'Não foi possível carregar os bairros: $message',
                      ),
                    ),
                    BairrosLoaded(:final bairros) => _MapaContent(
                      bairros: bairros,
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

class _MapaContent extends StatelessWidget {
  const _MapaContent({required this.bairros});

  final List<BairroResumoViewModel> bairros;

  @override
  Widget build(BuildContext context) {
    final alertas = bairros
        .where((bairro) => bairro.status != 'em_dia')
        .toList();

    return Row(
      children: [
        // Left: Map
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              GeopragMapPlaceholder(
                message: '[Mapa Interativo de Gaspar]\nBairros clicáveis',
                backgroundColor: Colors.green[50]!,
                borderColor: Colors.green[200]!,
                textColor: Colors.green,
              ),
              for (var i = 0; i < bairros.length; i++)
                Positioned(
                  top: _posicoesPinsMock[i % _posicoesPinsMock.length].dy,
                  left: _posicoesPinsMock[i % _posicoesPinsMock.length].dx,
                  child: _BairroPin(bairro: bairros[i]),
                ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Right: Legend & List
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Legenda',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: GeopragColors.statusEmDia,
                    ),
                    title: Text('Em dia (verde)'),
                    dense: true,
                  ),
                  const ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: GeopragColors.statusAtrasado,
                    ),
                    title: Text('Atrasado (vermelho)'),
                    dense: true,
                  ),
                  const ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: GeopragColors.statusDenuncia,
                    ),
                    title: Text('Foco Reportado (amarelo)'),
                    dense: true,
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Alertas Críticos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: GeopragColors.statusAtrasado,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: alertas.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhum alerta crítico no momento.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : ListView(
                            children: [
                              for (final bairro in alertas)
                                ListTile(
                                  title: Text(bairro.nome),
                                  subtitle: Text(
                                    '${bairro.diasSemAplicacao} dias sem aplicação',
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                  ),
                                  onTap: () {
                                    AdminNavigatorScope.of(
                                      context,
                                    ).toMapaBairro(bairro.id);
                                  },
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

class _BairroPin extends StatelessWidget {
  const _BairroPin({required this.bairro});

  final BairroResumoViewModel bairro;

  GeopragStatus get _status => switch (bairro.status) {
    'atrasado' => GeopragStatus.atrasado,
    'denuncia' => GeopragStatus.denuncia,
    _ => GeopragStatus.emDia,
  };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AdminNavigatorScope.of(context).toMapaBairro(bairro.id);
      },
      child: Column(
        children: [
          Icon(Icons.location_on, color: _status.color, size: 48),
          Text(
            bairro.nome,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
