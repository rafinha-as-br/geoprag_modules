import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/admin_scaffold.dart';
import 'corrego_detalhe_cubit.dart';
import 'corrego_detalhe_state.dart';
import 'corrego_view_model.dart';

/// Medições físicas completas de um [Corrego] específico (ver
/// [CorregoDetalhadoViewModel]).
class VisualizacaoDeCorregoScreen extends StatelessWidget {
  const VisualizacaoDeCorregoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/mapa',
      appBar: AppBar(title: const Text('Visualização de Córrego')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocBuilder<CorregoDetalheCubit, CorregoDetalheState>(
          builder: (context, state) {
            return switch (state) {
              CorregoDetalheLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              CorregoDetalheError(:final message) => Center(
                child: Text('Não foi possível carregar o córrego: $message'),
              ),
              CorregoDetalheLoaded(:final corrego) => _CorregoDetalheContent(
                corrego: corrego,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _CorregoDetalheContent extends StatelessWidget {
  const _CorregoDetalheContent({required this.corrego});

  final CorregoDetalhadoViewModel corrego;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          corrego.nome,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Bairro: ${corrego.bairro}',
          style: const TextStyle(color: Colors.black54, fontSize: 16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Medições do Trecho',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.straighten),
                  title: const Text('Largura'),
                  subtitle: Text('${corrego.largura} m'),
                ),
                ListTile(
                  leading: const Icon(Icons.vertical_align_bottom),
                  title: const Text('Profundidade'),
                  subtitle: Text('${corrego.profundidade} m'),
                ),
                ListTile(
                  leading: const Icon(Icons.speed),
                  title: const Text('Velocidade da água'),
                  subtitle: Text('${corrego.velocidade} m/s'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
