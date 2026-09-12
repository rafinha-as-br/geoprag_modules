import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/base_detail_screen.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../../widgets/admin_scaffold.dart';
import 'bairro_detalhe_cubit.dart';
import 'bairro_detalhe_state.dart';
import 'bairro_view_model.dart';
import 'corrego_view_model.dart';

/// Detalhe agregado de um [Bairro]: status geral e os córregos que o
/// atravessam (ver [BairroDetalhadoViewModel]).
class DetalheDoBairroScreen extends StatelessWidget {
  const DetalheDoBairroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/mapa',
      appBar: AppBar(title: const Text('Detalhe do Bairro')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocBuilder<BairroDetalheCubit, BairroDetalheState>(
          builder: (context, state) {
            final bairro = state is BairroDetalheLoaded ? state.bairro : null;

            return BaseDetailScreen(
              variant: BaseDetailScreenVariant.duasColunas,
              title: bairro?.nome ?? '',
              isLoading: state is BairroDetalheLoading,
              errorMessage: state is BairroDetalheError
                  ? 'Não foi possível carregar o bairro: ${state.message}'
                  : null,
              actions: bairro == null
                  ? const []
                  : [GeopragStatusBadge(status: _statusDe(bairro.status))],
              contentBuilder: (context) => bairro == null
                  ? const SizedBox.shrink()
                  : _BairroDetalheContent(bairro: bairro),
            );
          },
        ),
      ),
    );
  }
}

GeopragStatus _statusDe(String status) => switch (status) {
  'atrasado' => GeopragStatus.atrasado,
  'denuncia' => GeopragStatus.denuncia,
  _ => GeopragStatus.emDia,
};

class _BairroDetalheContent extends StatelessWidget {
  const _BairroDetalheContent({required this.bairro});

  final BairroDetalhadoViewModel bairro;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${bairro.diasSemAplicacao} dias sem aplicação',
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Córregos do Bairro',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Divider(),
                if (bairro.corregos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text(
                        'Nenhum córrego cadastrado para este bairro.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  )
                else
                  // BaseDetailScreen não dá altura limitada ao conteúdo (ver
                  // src/widgets/base_detail_screen.dart), então a lista
                  // rola dentro de uma altura máxima própria em vez de
                  // depender de um Expanded do ancestral, como antes da
                  // migração.
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final corrego in bairro.corregos)
                          _CorregoListTile(corrego: corrego),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CorregoListTile extends StatelessWidget {
  const _CorregoListTile({required this.corrego});

  final CorregoResumoViewModel corrego;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.water),
      title: Text(corrego.nome),
      subtitle: Text(corrego.bairro),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      // TODO(GEOPRAG-24): AdminNavigator ainda não expõe uma rota para
      // "visualizar córrego" — sem destino real para navegar ao tocar.
      onTap: () {},
    );
  }
}
