import 'package:flutter/material.dart';

class TelaEducativaScreen extends StatelessWidget {
  const TelaEducativaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Antes de denunciar...'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.school_outlined, size: 80, color: Color(0xFF2E7D32)),
            const SizedBox(height: 24),
            const Text(
              'O que é um foco de borrachudo?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'O borrachudo se reproduz em água corrente, limpa e com corredeiras. Remansos ou água parada NÃO são focos de borrachudo (embora possam ser de pernilongos ou dengue).',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            const Text(
              'Uma denúncia aciona a equipe da Secretaria de Agricultura para vistoria física. O uso indevido deste canal atrasa o atendimento a áreas críticas.',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.red),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Água corrente, pedras, folhas na correnteza.'),
                  ),
                  ListTile(
                    leading: Icon(Icons.cancel, color: Colors.red),
                    title: Text('Potes com água parada, caixas d\'água destampadas, poças.'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/denuncia/cadastro');
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
                'Entendi, avançar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
