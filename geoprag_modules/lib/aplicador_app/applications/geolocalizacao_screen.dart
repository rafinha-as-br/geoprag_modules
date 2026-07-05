import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: const Text('Validação de Ponto'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
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
                          ? const Color(0xFF2E7D32).withOpacity(0.2) 
                          : Colors.red.withOpacity(0.2),
                      border: Border.all(
                        color: _isDentroDoRaio ? const Color(0xFF2E7D32) : Colors.red,
                        width: 2,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.my_location, 
                    size: 48, 
                    color: _isDentroDoRaio ? const Color(0xFF2E7D32) : Colors.red,
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
                    _isDentroDoRaio ? 'Você chegou ao local!' : 'Desloque-se até o ponto',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _isDentroDoRaio ? const Color(0xFF2E7D32) : Colors.black87,
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
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isDentroDoRaio ? () {
                      Navigator.pushReplacementNamed(context, '/aplicacao/registrar');
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
      ),
    );
  }
}
