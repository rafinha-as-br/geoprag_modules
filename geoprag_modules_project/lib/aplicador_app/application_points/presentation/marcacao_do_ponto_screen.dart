import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../core/aplicador_navigator.dart';
import 'marcacao_do_ponto_cubit.dart';
import 'marcacao_do_ponto_state.dart';
import 'ponto_de_aplicacao_view_model.dart';

/// Tela de (re)marcação da localização inicial do ponto de aplicação via
/// GPS.
///
/// Assume que um [MarcacaoDoPontoCubit] já foi provido acima na árvore de
/// widgets (ver `AplicadorBootstrap.buildMarcacaoDoPontoCubit` em
/// `bootstrap.dart`).
class MarcacaoDoPontoScreen extends StatelessWidget {
  const MarcacaoDoPontoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marcação do Ponto Inicial')),
      body: BlocConsumer<MarcacaoDoPontoCubit, MarcacaoDoPontoState>(
        listener: (context, state) {
          if (state is MarcacaoDoPontoSalvo) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Localização capturada! Pendente de validação.'),
              ),
            );
            AplicadorNavigatorScope.of(context).back();
          }
        },
        builder: (context, state) {
          return switch (state) {
            MarcacaoDoPontoCapturando() => const Center(
              child: CircularProgressIndicator(),
            ),
            MarcacaoDoPontoErro(:final message) => Center(
              child: Text('Não foi possível capturar a localização: $message'),
            ),
            MarcacaoDoPontoSalvo() => const Center(
              child: CircularProgressIndicator(),
            ),
            MarcacaoDoPontoCapturado(:final captura, :final salvando) =>
              _MarcacaoDoPontoContent(captura: captura, salvando: salvando),
          };
        },
      ),
    );
  }
}

class _MarcacaoDoPontoContent extends StatelessWidget {
  const _MarcacaoDoPontoContent({
    required this.captura,
    required this.salvando,
  });

  final CapturaLocalizacaoViewModel captura;
  final bool salvando;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Área de mapa (posição capturada pelo GPS).
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            color: Colors.grey[200],
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  'https://static.vecteezy.com/system/resources/previews/000/153/588/original/vector-map-of-city-with-river.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Carregando mapa...'));
                  },
                ),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: GeopragColors.green900.withOpacity(0.2),
                    border: Border.all(color: GeopragColors.green900, width: 2),
                  ),
                ),
                const Icon(Icons.location_on, size: 48, color: Colors.red),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Configure seu Ponto de Aplicação',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Vá fisicamente até o local de início do seu ponto de aplicação e clique em "Capturar Localização". O ponto será enviado para a prefeitura validar.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.gps_fixed,
                        color: GeopragColors.green900,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Precisão atual: ${captura.qualidadePrecisao} '
                              '(${captura.precisaoMetros.toStringAsFixed(0)}m)',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              captura.coordenadasFormatadas,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: salvando
                      ? null
                      : () => context.read<MarcacaoDoPontoCubit>().salvar(),
                  icon: salvando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Salvar Ponto Inicial'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    AplicadorNavigatorScope.of(context).back();
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
