import 'package:flutter/material.dart';

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
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
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
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2E7D32), width: 4),
              ),
              child: const Column(
                children: [
                  Icon(Icons.water_drop, size: 48, color: Color(0xFF2E7D32)),
                  SizedBox(height: 8),
                  Text(
                    dosagem,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
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
              leading: Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32)),
              title: Text('Despeje a dosagem exata indicada acima na correnteza do córrego.'),
              contentPadding: EdgeInsets.zero,
            ),
            const ListTile(
              leading: Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32)),
              title: Text('Evite aplicar em remansos ou água parada.'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                // Simulate confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Aplicação registrada com sucesso! (Sincronizado)'),
                    backgroundColor: Color(0xFF2E7D32),
                  ),
                );
                // Return to home
                Navigator.pushReplacementNamed(context, '/ponto');
              },
              icon: const Icon(Icons.check),
              label: const Text('Confirmar Aplicação'),
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
