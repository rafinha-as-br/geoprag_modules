import 'package:flutter/material.dart';

class MarcacaoDoPontoScreen extends StatelessWidget {
  const MarcacaoDoPontoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marcação do Ponto Inicial'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Simulated Map View Area
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
                      color: const Color(0xFF2E7D32).withOpacity(0.2),
                      border: Border.all(color: const Color(0xFF2E7D32), width: 2),
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
                    'Configure seu Trecho',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vá fisicamente até o local de início do seu trecho de aplicação e clique em "Capturar Localização". O ponto será enviado para a prefeitura validar.',
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
                    child: const Row(
                      children: [
                        Icon(Icons.gps_fixed, color: Color(0xFF2E7D32)),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Precisão atual: Alta (4m)', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('-26.9312, -48.9567', style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Localização capturada! Pendente de validação.')),
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Salvar Ponto Inicial'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
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
