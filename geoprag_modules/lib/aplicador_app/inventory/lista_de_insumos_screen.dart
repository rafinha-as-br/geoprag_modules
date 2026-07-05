import 'package:flutter/material.dart';

class ListaDeInsumosScreen extends StatelessWidget {
  const ListaDeInsumosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventário'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Stock Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(Icons.inventory, size: 48, color: Color(0xFF2E7D32)),
                    const SizedBox(height: 16),
                    const Text(
                      'Estoque Atual',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '950 ml',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'BTI Líquido - Última atualização hoje',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Ações',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Pending Deliveries Button
            InkWell(
              onTap: () {
                // Navigate to pending deliveries (Recebimentos)
                Navigator.pushNamed(context, '/recebimentos');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9), // Light green
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_shipping_outlined, color: Color(0xFF2E7D32)),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recebimentos Pendentes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          Text(
                            '2 produtos a caminho',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Color(0xFF2E7D32), size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Inventário tab
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/ponto');
          if (index == 2) Navigator.pushReplacementNamed(context, '/denuncias');
        },
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Insumos'),
          BottomNavigationBarItem(icon: Icon(Icons.report_problem_outlined), label: 'Denúncias'),
        ],
      ),
    );
  }
}
