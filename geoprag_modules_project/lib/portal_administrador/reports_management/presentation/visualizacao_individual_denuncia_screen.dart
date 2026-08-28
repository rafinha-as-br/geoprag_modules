import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/base_detail_screen.dart';
import '../../widgets/admin_scaffold.dart';
import 'denuncia_detalhe_cubit.dart';
import 'denuncia_detalhe_state.dart';
import 'denuncia_view_model.dart';

class VisualizacaoIndividualDenunciaScreen extends StatelessWidget {
  const VisualizacaoIndividualDenunciaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/denuncias_admin',
      appBar: AppBar(title: const Text('Análise da Denúncia')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocBuilder<DenunciaDetalheCubit, DenunciaDetalheState>(
          builder: (context, state) {
            final denuncia = state is DenunciaDetalheLoaded
                ? state.denuncia
                : null;

            return BaseDetailScreen(
              variant: BaseDetailScreenVariant.duasColunas,
              title: 'Detalhes do Foco Reportado',
              isLoading: state is DenunciaDetalheLoading,
              errorMessage: state is DenunciaDetalheError
                  ? 'Não foi possível carregar a denúncia: ${state.message}'
                  : null,
              contentBuilder: (context) => denuncia == null
                  ? const SizedBox.shrink()
                  : _DenunciaDetalheContent(denuncia: denuncia),
            );
          },
        ),
      ),
    );
  }
}

class _DenunciaDetalheContent extends StatelessWidget {
  const _DenunciaDetalheContent({required this.denuncia});

  final DenunciaDetalhadaViewModel denuncia;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Detalhes da Denúncia
        Expanded(
          flex: 1,
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
                    'Informações Originais',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Data e Hora'),
                    subtitle: Text(denuncia.dataHoraFormatada),
                  ),
                  ListTile(
                    title: const Text('Denunciante'),
                    subtitle: Text(denuncia.denunciante),
                  ),
                  ListTile(
                    title: const Text('Nível de Infestação'),
                    subtitle: Text(
                      denuncia.nivelInfestacao,
                      style: TextStyle(
                        color: _corNivel(denuncia.nivelInfestacao),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Descrição do Local'),
                    subtitle: Text(denuncia.descricao),
                  ),
                  ListTile(
                    title: const Text('Observações Extras'),
                    subtitle: Text(denuncia.observacoes),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Center(
                      child: Text(
                        '[Mapa estático com Pin GPS: '
                        '${denuncia.lat}, ${denuncia.lng}]',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Gestão de Status e Histórico
        Expanded(
          flex: 1,
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
                    'Ações Resolutivas e Status',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: denuncia.status,
                    decoration: const InputDecoration(
                      labelText: 'Status Atual',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Recebida',
                        child: Text('Recebida'),
                      ),
                      DropdownMenuItem(
                        value: 'Equipe a Investigar',
                        child: Text('Equipe a Investigar'),
                      ),
                      DropdownMenuItem(
                        value: 'Em Combate',
                        child: Text('Em Combate'),
                      ),
                      DropdownMenuItem(
                        value: 'Resolvido',
                        child: Text('Resolvido'),
                      ),
                    ],
                    onChanged: (val) {},
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.save),
                    label: const Text('Atualizar Status'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Histórico de Auditoria',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Divider(),
                  if (denuncia.historico.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Nenhum registro de auditoria até o momento.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    for (final registro in denuncia.historico)
                      ListTile(
                        leading: const Icon(Icons.history, color: Colors.grey),
                        title: Text(registro.titulo),
                        subtitle: Text(
                          'Por: ${registro.autor} em ${registro.dataHoraFormatada}\n'
                          'Status: ${registro.status}',
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

Color _corNivel(String nivel) {
  switch (nivel) {
    case 'Alto':
      return GeopragColors.statusAtrasado;
    case 'Médio':
      return GeopragColors.statusDenuncia;
    default:
      return GeopragColors.statusEmDia;
  }
}
