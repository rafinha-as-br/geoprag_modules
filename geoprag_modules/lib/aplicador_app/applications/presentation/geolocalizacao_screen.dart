import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../core/aplicador_navigator.dart';

class GeolocalizacaoScreen extends StatefulWidget {
  const GeolocalizacaoScreen({super.key});

  @override
  State<GeolocalizacaoScreen> createState() => _GeolocalizacaoScreenState();
}

class _GeolocalizacaoScreenState extends State<GeolocalizacaoScreen> {
  bool _isDentroDoRaio = false; // Mocking the geofence validation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validação de Ponto')),
      body: Column(
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
                      color: _isDentroDoRaio
                          ? GeopragColors.statusEmDia.withOpacity(0.2)
                          : GeopragColors.statusAtrasado.withOpacity(0.2),
                      border: Border.all(
                        color: _isDentroDoRaio
                            ? GeopragColors.statusEmDia
                            : GeopragColors.statusAtrasado,
                        width: 2,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.my_location,
                    size: 48,
                    color: _isDentroDoRaio
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
                    _isDentroDoRaio
                        ? 'Você chegou ao local!'
                        : 'Desloque-se até o ponto',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _isDentroDoRaio
                          ? GeopragColors.statusEmDia
                          : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isDentroDoRaio
                        ? 'Sua localização atual corresponde ao Ponto Inicial cadastrado. Você pode prosseguir com o registro da aplicação.'
                        : 'Você está fora do raio de cobertura permitido do Ponto Inicial (aprox. 150m de distância).',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (!_isDentroDoRaio)
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isDentroDoRaio = true;
                        });
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
                    onPressed: _isDentroDoRaio
                        ? () {
                            AplicadorNavigatorScope.of(
                              context,
                            ).toAplicacaoRegistrar();
                          }
                        : null,
                    child: const Text(
                      'Iniciar Aplicação',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
