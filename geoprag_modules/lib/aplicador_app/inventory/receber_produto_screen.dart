import 'package:flutter/material.dart';

class ReceberProdutoScreen extends StatelessWidget {
  const ReceberProdutoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Recebimento'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.inventory_2, size: 80, color: Color(0xFF2E7D32)),
            const SizedBox(height: 24),
            const Text(
              'BTI Líquido - 1 Litro',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detalhes da Entrega', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Divider(),
                  SizedBox(height: 8),
                  Text('Agente Entregador:', style: TextStyle(color: Colors.grey)),
                  Text('João Silva (Fiscal de Agricultura)', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Text('Data de Despacho:', style: TextStyle(color: Colors.grey)),
                  Text('05/07/2026 às 14:30', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Text('Quantidade / Volume:', style: TextStyle(color: Colors.grey)),
                  Text('1 Litro', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Recebimento confirmado! Estoque atualizado.'),
                    backgroundColor: Color(0xFF2E7D32),
                  ),
                );
                // Return to inventory
                Navigator.pushReplacementNamed(context, '/inventario');
              },
              icon: const Icon(Icons.check),
              label: const Text('Confirmar Recebimento'),
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
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
