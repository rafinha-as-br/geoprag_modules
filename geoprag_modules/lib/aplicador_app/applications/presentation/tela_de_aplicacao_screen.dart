import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_colors.dart';

class TelaDeAplicacaoScreen extends StatelessWidget {
  const TelaDeAplicacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulated data from API
    const dosagem = '50 ml';
    const volumeAtual = '950 ml disponíveis no inventário';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Execução da Aplicação'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Dosagem Recomendada',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: GeopragColors.green900.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: GeopragColors.green900, width: 4),
              ),
              child: Column(
                children: [
                  Icon(Icons.water_drop, size: 48, color: GeopragColors.green900),
                  const SizedBox(height: 8),
                  Text(
                    dosagem,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: GeopragColors.green900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              volumeAtual,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            const Text(
              'Instruções:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const ListTile(
              leading: Icon(Icons.check_circle_outline, color: GeopragColors.green900),
              title: Text('Despeje a dosagem exata indicada acima na correnteza do córrego.'),
              contentPadding: EdgeInsets.zero,
            ),
            const ListTile(
              leading: Icon(Icons.check_circle_outline, color: GeopragColors.green900),
              title: Text('Evite aplicar em remansos ou água parada.'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                // Simulate confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Aplicação registrada com sucesso! (Sincronizado)'),
                    backgroundColor: GeopragColors.green900,
                  ),
                );
                // Return to home
                Navigator.pushReplacementNamed(context, '/ponto');
              },
              icon: const Icon(Icons.check),
              label: const Text('Confirmar Aplicação'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancelar / Voltar',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
