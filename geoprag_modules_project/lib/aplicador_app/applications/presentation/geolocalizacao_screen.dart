import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../core/aplicador_navigator.dart';
import 'aplicacao_view_model.dart';
import 'geolocalizacao_cubit.dart';
import 'geolocalizacao_state.dart';

class GeolocalizacaoScreen extends StatelessWidget {
  const GeolocalizacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validação de Ponto')),
      body: BlocBuilder<GeolocalizacaoCubit, GeolocalizacaoState>(
        builder: (context, state) {
          return switch (state) {
            GeolocalizacaoLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            GeolocalizacaoError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Não foi possível carregar o ponto de aplicação: $message',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            GeolocalizacaoLoaded(:final aplicacao, :final dentroDoRaio) =>
              _GeolocalizacaoContent(
                aplicacao: aplicacao,
                dentroDoRaio: dentroDoRaio,
              ),
          };
        },
      ),
    );
  }
}

class _GeolocalizacaoContent extends StatelessWidget {
  const _GeolocalizacaoContent({
    required this.aplicacao,
    required this.dentroDoRaio,
  });

  final AplicacaoAtualViewModel aplicacao;
  final bool dentroDoRaio;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                // Mock radar / distance
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dentroDoRaio
                        ? GeopragColors.statusEmDia.withOpacity(0.2)
                        : GeopragColors.statusAtrasado.withOpacity(0.2),
                    border: Border.all(
                      color: dentroDoRaio
                          ? GeopragColors.statusEmDia
                          : GeopragColors.statusAtrasado,
                      width: 2,
                    ),
                  ),
                ),
                Icon(
                  Icons.my_location,
                  size: 48,
                  color: dentroDoRaio
                      ? GeopragColors.statusEmDia
                      : GeopragColors.statusAtrasado,
                ),
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
                Text(
                  dentroDoRaio
                      ? 'Você chegou ao local!'
                      : 'Desloque-se até o ponto',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: dentroDoRaio
                        ? GeopragColors.statusEmDia
                        : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  dentroDoRaio
                      ? 'Sua localização atual corresponde ao ponto em '
                            '${aplicacao.localizacaoFormatada}. Você pode '
                            'prosseguir com o registro da aplicação.'
                      : 'Você está fora do raio de cobertura permitido do '
                            'ponto em ${aplicacao.localizacaoFormatada} '
                            '(aprox. 150m de distância).',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (!dentroDoRaio)
                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<GeolocalizacaoCubit>().confirmarChegada();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Simular chegada ao ponto (Mock)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: GeopragColors.blue600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: dentroDoRaio
                      ? () {
                          AplicadorNavigatorScope.of(
                            context,
                          ).toAplicacaoRegistrar();
                        }
                      : null,
                  child: const Text(
                    'Iniciar Aplicação',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
