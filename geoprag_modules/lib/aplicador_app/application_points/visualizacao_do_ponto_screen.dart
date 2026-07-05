import 'package:flutter/material.dart';

class VisualizacaoDoPontoScreen extends StatefulWidget {
  const VisualizacaoDoPontoScreen({super.key});

  @override
  State<VisualizacaoDoPontoScreen> createState() => _VisualizacaoDoPontoScreenState();
}

class _VisualizacaoDoPontoScreenState extends State<VisualizacaoDoPontoScreen> {
  int _selectedIndex = 0;
  // Simulating the user's cycle status for demonstration (true = on time, false = delayed)
  final bool _isNoPrazo = true; 

  @override
  Widget build(BuildContext context) {
    final statusColor = _isNoPrazo ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F);
    final statusText = _isNoPrazo ? 'Ciclo no Prazo' : 'Aplicação Atrasada';
    final statusIcon = _isNoPrazo ? Icons.check_circle_outline : Icons.warning_amber_rounded;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Ponto'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bem-vindo, Voluntário!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aqui está o resumo do seu trecho de atuação atual.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 32),
            // Application Point Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(statusIcon, color: statusColor),
                          const SizedBox(width: 8),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Córrego Gasparinho - Trecho 01',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Rua Pedro Simon, Margem Esquerda',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Última Aplicação', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  Text(
                                    '10/05/2026',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Próxima (Estimada)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  Text(
                                    '25/05/2026',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/aplicacao/info');
                              },
                              icon: const Icon(Icons.water_drop),
                              label: const Text('Registrar Aplicação'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: statusColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/ponto/marcar');
              },
              icon: const Icon(Icons.edit_location_alt_outlined),
              label: const Text('Remarcar Ponto Inicial (GPS)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // MVP routing simulation
          if (index == 1) Navigator.pushReplacementNamed(context, '/inventario');
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
