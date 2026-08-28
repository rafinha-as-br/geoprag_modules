import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/base_card_list_screen.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../../widgets/admin_scaffold.dart';
import '../../autenticacao/core/admin_navigator.dart';
import 'bairro_view_model.dart';
import 'bairros_cubit.dart';
import 'bairros_state.dart';

/// Lista de bairros monitorados com o status agregado dos córregos de cada
/// um (ver [BairroResumoViewModel]).
class MapaDeBairrosScreen extends StatelessWidget {
  const MapaDeBairrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/mapa',
      appBar: AppBar(title: const Text('Bairros Monitorados')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bairros Monitorados',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Situação dos córregos agregada por bairro.',
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: BlocBuilder<BairrosCubit, BairrosState>(
                  builder: (context, state) {
                    return BaseCardListScreen<BairroResumoViewModel>(
                      model: BaseCardListScreenModel(
                        isLoading: state is BairrosLoading,
                        errorMessage: state is BairrosError
                            ? 'Não foi possível carregar os bairros: ${state.message}'
                            : null,
                        items: state is BairrosLoaded ? state.bairros : null,
                        itemBuilder: (context, bairro) =>
                            _BairroListTile(bairro: bairro),
                        padding: const EdgeInsets.all(8),
                        emptyStateMessage: 'Nenhum bairro encontrado.',
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BairroListTile extends StatelessWidget {
  const _BairroListTile({required this.bairro});

  final BairroResumoViewModel bairro;

  GeopragStatus get _status => switch (bairro.status) {
    'atrasado' => GeopragStatus.atrasado,
    'denuncia' => GeopragStatus.denuncia,
    _ => GeopragStatus.emDia,
  };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.location_city),
      title: Text(bairro.nome),
      subtitle: Text('${bairro.diasSemAplicacao} dias sem aplicação'),
      trailing: GeopragStatusBadge(status: _status, dense: true),
      onTap: () {
        AdminNavigatorScope.of(context).toMapaBairro(bairro.id);
      },
    );
  }
}
