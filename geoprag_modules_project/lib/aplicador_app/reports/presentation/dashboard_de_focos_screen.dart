import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/aplicador_bottom_nav.dart';
import '../../../src/widgets/base_card_list_screen.dart';
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
                return Column(
                  children: [
                    if (state is DenunciasDeFocoLoaded)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Text(
                          'Suas denúncias recentes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    Expanded(
                      child: BaseCardListScreen<DenunciaDeFocoViewModel>(
                        isLoading: state is DenunciasDeFocoLoading,
                        errorMessage: state is DenunciasDeFocoError
                            ? 'Não foi possível carregar suas denúncias: ${state.message}'
                            : null,
                        items: state is DenunciasDeFocoLoaded
                            ? state.denuncias
                            : null,
                        itemBuilder: (context, denuncia) =>
                            _buildDenunciaCard(denuncia),
                        separatorBuilder: (context, index) =>
                            const SizedBox(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        emptyStateMessage: 'Nenhuma denúncia registrada.',
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AplicadorBottomNav(currentIndex: 2),
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
