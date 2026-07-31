import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/entities/usuario.dart';
import '../../../src/theme/geoprag_colors.dart';
import '../../widgets/admin_scaffold.dart';
import '../core/atuacao_aplicador.dart';
import 'aplicador_detalhe_cubit.dart';
import 'aplicador_detalhe_state.dart';
import 'aplicador_view_model.dart';

class VisualizacaoIndividualScreen extends StatelessWidget {
  const VisualizacaoIndividualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/aplicadores',
      appBar: AppBar(title: const Text('Detalhes do Aplicador')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocBuilder<AplicadorDetalheCubit, AplicadorDetalheState>(
          builder: (context, state) {
            return switch (state) {
              AplicadorDetalheLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              AplicadorDetalheError(:final message) => Text(
                'Não foi possível carregar o aplicador: $message',
              ),
              AplicadorDetalheLoaded(:final aplicador) =>
                _AplicadorDetalheContent(aplicador: aplicador),
            };
          },
        ),
      ),
    );
  }
}

class _AplicadorDetalheContent extends StatelessWidget {
  const _AplicadorDetalheContent({required this.aplicador});

  final AplicadorDetalhadoViewModel aplicador;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              aplicador.nome,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Cadastro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.delete),
                  label: const Text('Excluir (Lógico)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GeopragColors.statusAtrasado,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Perfil
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
                        'Informações Pessoais',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('CPF'),
                        subtitle: Text(aplicador.cpf),
                      ),
                      ListTile(
                        title: const Text('Telefone'),
                        subtitle: Text(aplicador.telefone),
                      ),
                      ListTile(
                        title: const Text('Endereço'),
                        subtitle: Text(aplicador.endereco),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Status do Cadastro',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<UsuarioStatus>(
                        initialValue: aplicador.status,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: UsuarioStatus.ativo,
                            child: Text('Ativo'),
                          ),
                          DropdownMenuItem(
                            value: UsuarioStatus.desativado,
                            child: Text('Desativado'),
                          ),
                        ],
                        onChanged: (val) {},
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Acesso liberado ou bloqueado ao aplicativo móvel.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Histórico
            Expanded(
              flex: 2,
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
                        'Histórico de Atuações',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Divider(),
                      for (final atuacao in aplicador.historico)
                        ListTile(
                          leading: Icon(
                            atuacao.tipo == AtuacaoAplicadorTipo.aplicacao
                                ? Icons.water_drop
                                : Icons.inventory_2,
                            color:
                                atuacao.tipo == AtuacaoAplicadorTipo.aplicacao
                                ? Colors.blue
                                : GeopragColors.statusEmDia,
                          ),
                          title: Text(atuacao.titulo),
                          subtitle: Text(atuacao.subtitulo),
                          trailing: Text(atuacao.valor),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
