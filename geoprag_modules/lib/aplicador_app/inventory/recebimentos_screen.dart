import 'package:flutter/material.dart';

class RecebimentosScreen extends StatelessWidget {
  const RecebimentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recebimentos Pendentes'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Selecione o produto para confirmar o recebimento:',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.science_outlined, color: Color(0xFF2E7D32)),
              ),
              title: const Text('BTI Líquido - 1 Litro', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Enviado por: João Silva (Prefeitura)\nData: 05/07/2026'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, '/recebimento/confirmar');
              },
            ),
          ),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.science_outlined, color: Color(0xFF2E7D32)),
              ),
              title: const Text('BTI Sólido - 500g', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Enviado por: João Silva (Prefeitura)\nData: 03/07/2026'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, '/recebimento/confirmar');
              },
            ),
          ),
        ],
      ),
    );
  }
}
