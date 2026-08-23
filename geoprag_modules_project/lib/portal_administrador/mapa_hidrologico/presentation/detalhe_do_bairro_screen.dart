import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_status.dart';
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
            return switch (state) {
              BairroDetalheLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              BairroDetalheError(:final message) => Center(
                child: Text('Não foi possível carregar o bairro: $message'),
              ),
              BairroDetalheLoaded(:final bairro) => _BairroDetalheContent(
                bairro: bairro,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _BairroDetalheContent extends StatelessWidget {
  const _BairroDetalheContent({required this.bairro});

  final BairroDetalhadoViewModel bairro;

  GeopragStatus get _status => switch (bairro.status) {
    'atrasado' => GeopragStatus.atrasado,
    'denuncia' => GeopragStatus.denuncia,
    _ => GeopragStatus.emDia,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              bairro.nome,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            GeopragStatusBadge(status: _status),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${bairro.diasSemAplicacao} dias sem aplicação',
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Card(
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
                  Expanded(
                    child: bairro.corregos.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhum córrego cadastrado para este bairro.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : ListView(
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
