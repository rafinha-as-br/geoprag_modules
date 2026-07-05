import 'package:flutter/material.dart';

class TelaInformativaScreen extends StatelessWidget {
  const TelaInformativaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Aplicação'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 80,
              color: Color(0xFF1976D2), // Blue for information
            ),
            const SizedBox(height: 24),
            const Text(
              'Atenção',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
              ),
              child: const Text(
                'O registro da aplicação é um processo sério e não pode ser desfeito ou editado após a confirmação.\n\n'
                'Este registro gera a prova de auditoria para a Secretaria de Agricultura de que o produto biológico foi efetivamente utilizado no combate ao borrachudo no seu trecho.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Por favor, inicie o processo apenas quando estiver fisicamente no local de aplicação e pronto para despejar o produto.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/aplicacao/geo');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Estou ciente, continuar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
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
    );
  }
}
