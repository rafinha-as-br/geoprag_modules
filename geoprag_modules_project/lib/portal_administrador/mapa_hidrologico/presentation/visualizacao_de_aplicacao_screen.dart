import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/admin_scaffold.dart';
import 'aplicacao_mapa_cubit.dart';
import 'aplicacao_mapa_state.dart';
import 'aplicacao_mapa_view_model.dart';

/// Visualização, no mapa, de uma Aplicação (evento de aplicação de
/// inseticida) específica. Ver `core/aplicacao_mapa_repository.dart` para a
/// decisão de arquitetura sobre a leitura cross-portal da entidade
/// `Aplicacao` (modelada em `src/entities/aplicacao.dart`).
class VisualizacaoDeAplicacaoScreen extends StatelessWidget {
  const VisualizacaoDeAplicacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/mapa',
      appBar: AppBar(title: const Text('Visualização de Aplicação')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocBuilder<AplicacaoMapaCubit, AplicacaoMapaState>(
          builder: (context, state) {
            return switch (state) {
              AplicacaoMapaLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              AplicacaoMapaError(:final message) => Center(
                child: Text('Não foi possível carregar a aplicação: $message'),
              ),
              AplicacaoMapaLoaded(:final aplicacao) => _AplicacaoDetalheContent(
                aplicacao: aplicacao,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _AplicacaoDetalheContent extends StatelessWidget {
  const _AplicacaoDetalheContent({required this.aplicacao});

  final AplicacaoMapaViewModel aplicacao;

  String get _dataFormatada {
    final data = aplicacao.data;
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Aplicação Registrada',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Registrada em $_dataFormatada',
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder de mapa com o ponto da aplicação
            Expanded(
              flex: 2,
              child: Container(
                height: 260,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Colors.blue, size: 48),
                      Text(
                        '[Mapa Interativo]\nPonto da aplicação',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.green),
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
                        'Detalhes da Aplicação',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.science),
                        title: const Text('Dosagem'),
                        subtitle: Text('${aplicacao.dosagem} ml'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.my_location),
                        title: const Text('Coordenadas'),
                        subtitle: Text('${aplicacao.lat}, ${aplicacao.lng}'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Aplicador'),
                        // TODO(GEOPRAG-24): exibir o nome do aplicador exige
                        // agregar com AplicadorRepository.buscarPorId — fora
                        // do escopo mínimo desta tela por ora.
                        subtitle: Text(aplicacao.aplicadorId),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
