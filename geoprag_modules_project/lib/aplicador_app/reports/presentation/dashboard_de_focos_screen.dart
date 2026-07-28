import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../core/aplicador_navigator.dart';
import 'denuncia_de_foco_view_model.dart';
import 'denuncias_de_foco_cubit.dart';
import 'denuncias_de_foco_state.dart';

class DashboardDeFocosScreen extends StatelessWidget {
  const DashboardDeFocosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Denúncias de Foco')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: GeopragColors.green900,
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton.icon(
              onPressed: () {
                AplicadorNavigatorScope.of(context).toDenunciaEducativa();
              },
              icon: const Icon(Icons.add_alert),
              label: const Text('Criar Nova Denúncia'),
              style: ElevatedButton.styleFrom(
                backgroundColor: GeopragColors.white,
                foregroundColor: GeopragColors.green900,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<DenunciasDeFocoCubit, DenunciasDeFocoState>(
              builder: (context, state) {
                return switch (state) {
                  DenunciasDeFocoLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  DenunciasDeFocoError(:final message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Não foi possível carregar suas denúncias: $message',
                      ),
                    ),
                  ),
                  DenunciasDeFocoLoaded(:final denuncias) => ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'Suas denúncias recentes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      for (final denuncia in denuncias)
                        _buildDenunciaCard(denuncia),
                    ],
                  ),
                };
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Denúncias tab
        onTap: (index) {
          final navigator = AplicadorNavigatorScope.of(context);
          if (index == 0) navigator.toPonto();
          if (index == 1) navigator.toInventario();
        },
        selectedItemColor: GeopragColors.green900,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Insumos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem_outlined),
            label: 'Denúncias',
          ),
        ],
      ),
    );
  }

  Widget _buildDenunciaCard(DenunciaDeFocoViewModel denuncia) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: denuncia.atendida
              ? GeopragColors.statusEmDia
              : GeopragColors.statusDenuncia,
          child: Icon(
            denuncia.atendida ? Icons.check : Icons.warning,
            color: Colors.white,
          ),
        ),
        title: Text(
          denuncia.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Status: ${denuncia.statusLabel}\nData: ${denuncia.dataFormatada}',
        ),
      ),
    );
  }
}
