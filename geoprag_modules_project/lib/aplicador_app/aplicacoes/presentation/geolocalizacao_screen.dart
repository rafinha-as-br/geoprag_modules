import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/geoprag_map_placeholder.dart';
import '../../core/aplicador_navigator.dart';
import 'aplicacao_de_campo_view_model.dart';
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
            GeolocalizacaoLoaded(:final ponto, :final dentroDoRaio) =>
              _GeolocalizacaoContent(ponto: ponto, dentroDoRaio: dentroDoRaio),
          };
        },
      ),
    );
  }
}

class _GeolocalizacaoContent extends StatelessWidget {
  const _GeolocalizacaoContent({
    required this.ponto,
    required this.dentroDoRaio,
  });

  final PontoParaAplicacaoViewModel ponto;
  final bool dentroDoRaio;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned.fill(
                  child: GeopragMapPlaceholder(
                    message: '[Mapa Interativo]',
                    backgroundColor: Colors.grey,
                    borderColor: Colors.grey,
                    textColor: Colors.black54,
                  ),
                ),
                // Trajeto da visita anterior (só na revisita) — moldura da
                // distinção primeira aplicação/revisita, sem cálculo real de
                // rota (GEOPRAG-75).
                if (!ponto.primeiraAplicacao)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: GeopragColors.green900,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timeline,
                            size: 16,
                            color: GeopragColors.green900,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Trajeto da visita anterior',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
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
                  ponto.primeiraAplicacao
                      ? 'Primeira aplicação neste ponto'
                      : 'Revisita — ${ponto.execucoesRegistradas} aplicação(ões) anterior(es)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
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
                      ? 'Sua localização atual corresponde ao ponto '
                            '${ponto.nome} (${ponto.enderecoFormatado}). Você '
                            'pode prosseguir com o registro da aplicação.'
                      : 'Você está fora do raio de cobertura permitido do '
                            'ponto ${ponto.nome} (${ponto.enderecoFormatado}) '
                            '(aprox. ${ponto.distanciaEntreSubpontosMetros.round()}m de distância).',
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
                          ).toAplicacaoRegistrar(ponto.id);
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
