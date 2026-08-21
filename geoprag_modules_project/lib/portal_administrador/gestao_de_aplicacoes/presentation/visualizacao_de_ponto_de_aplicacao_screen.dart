import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../widgets/sidebar_menu.dart';
import 'ponto_de_aplicacao_detalhe_cubit.dart';
import 'ponto_de_aplicacao_detalhe_state.dart';
import 'status_ponto_de_aplicacao_badge.dart';
import 'validators/ponto_de_aplicacao_validators.dart';
import 'view_models/aplicador_opcao_view_model.dart';
import 'view_models/ponto_de_aplicacao_detalhe_view_model.dart';

class VisualizacaoDePontoDeAplicacaoScreen extends StatelessWidget {
  const VisualizacaoDePontoDeAplicacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ponto de Aplicação')),
      body: Row(
        children: [
          const SidebarMenu(currentRoute: '/aplicacoes'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: BlocConsumer<
                PontoDeAplicacaoDetalheCubit,
                PontoDeAplicacaoDetalheState
              >(
                listener: (context, state) {
                  if (state is PontoDeAplicacaoDetalheError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  return switch (state) {
                    PontoDeAplicacaoDetalheLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    PontoDeAplicacaoDetalheError(:final message) => Center(
                      child: Text(
                        'Não foi possível carregar o ponto de aplicação: $message',
                      ),
                    ),
                    PontoDeAplicacaoDetalheLoaded(:final ponto) =>
                      _PontoConteudo(viewModel: ponto),
                  };
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PontoConteudo extends StatelessWidget {
  final PontoDeAplicacaoDetalheViewModel viewModel;

  const _PontoConteudo({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  viewModel.bairro,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                StatusPontoDeAplicacaoBadge(status: viewModel.status),
                if (!viewModel.ativo) ...[
                  const SizedBox(width: 8),
                  const Chip(label: Text('Desativado')),
                ],
              ],
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: viewModel.podeEditar
                      ? () => _abrirEdicaoDePonto(context, viewModel)
                      : null,
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Ponto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                if (viewModel.podeDesativar)
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<PontoDeAplicacaoDetalheCubit>().desativar(),
                    icon: const Icon(Icons.block),
                    label: const Text('Desativar Ponto'),
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
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          'Dados do Ponto',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('Coordenadas'),
                          subtitle: Text(
                            '${viewModel.lat.toStringAsFixed(4)}, ${viewModel.lng.toStringAsFixed(4)}',
                          ),
                        ),
                        ListTile(
                          title: const Text('Distância do alerta de subponto'),
                          subtitle: Text(
                            '${viewModel.distanciaAlertaMetros.toStringAsFixed(0)}m',
                          ),
                        ),
                        ListTile(
                          title: const Text('Intervalo entre aplicações'),
                          subtitle: Text(
                            '${viewModel.intervaloDiasEntreAplicacoes} dias',
                          ),
                        ),
                        if (viewModel.dataAgendada != null)
                          ListTile(
                            title: const Text('Data Agendada'),
                            subtitle: Text(
                              _formatarData(viewModel.dataAgendada!),
                            ),
                          ),
                        if (viewModel.dataConcluida != null)
                          ListTile(
                            title: const Text('Data Concluída'),
                            subtitle: Text(
                              _formatarData(viewModel.dataConcluida!),
                            ),
                          ),
                        const SizedBox(height: 16),
                        const Text(
                          'Aplicador Responsável',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _AtribuicaoDeAplicador(viewModel: viewModel),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
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
                          'Registro Manual da Aplicação',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Divider(),
                        const Text(
                          'Fluxo de registro manual pelo portal ainda '
                          'não detalhado com o Rafael.',
                          style: TextStyle(color: Colors.black54),
                        ),
                        // TODO(GEOPRAG-38): detalhar fluxo de
                        // registro manual junto ao Rafael.
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatarData(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
}

Future<void> _abrirEdicaoDePonto(
  BuildContext context,
  PontoDeAplicacaoDetalheViewModel viewModel,
) {
  final cubit = context.read<PontoDeAplicacaoDetalheCubit>();
  return showDialog<void>(
    context: context,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _EditarPontoDialog(viewModel: viewModel),
    ),
  );
}

class _EditarPontoDialog extends StatefulWidget {
  final PontoDeAplicacaoDetalheViewModel viewModel;

  const _EditarPontoDialog({required this.viewModel});

  @override
  State<_EditarPontoDialog> createState() => _EditarPontoDialogState();
}

class _EditarPontoDialogState extends State<_EditarPontoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _bairroController = TextEditingController(
    text: widget.viewModel.bairro,
  );
  late final _latController = TextEditingController(
    text: widget.viewModel.lat.toString(),
  );
  late final _lngController = TextEditingController(
    text: widget.viewModel.lng.toString(),
  );
  late final _distanciaAlertaController = TextEditingController(
    text: widget.viewModel.distanciaAlertaMetros.toString(),
  );
  late final _intervaloDiasController = TextEditingController(
    text: widget.viewModel.intervaloDiasEntreAplicacoes.toString(),
  );

  @override
  void dispose() {
    _bairroController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _distanciaAlertaController.dispose();
    _intervaloDiasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Ponto de Aplicação'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _bairroController,
                decoration: const InputDecoration(
                  labelText: 'Bairro',
                  border: OutlineInputBorder(),
                ),
                validator: PontoDeAplicacaoValidators.bairro,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: PontoDeAplicacaoValidators.coordenada,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: PontoDeAplicacaoValidators.coordenada,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _distanciaAlertaController,
                decoration: const InputDecoration(
                  labelText: 'Distância do alerta de subponto (m)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: PontoDeAplicacaoValidators.distanciaAlertaMetros,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _intervaloDiasController,
                decoration: const InputDecoration(
                  labelText: 'Intervalo entre aplicações (dias)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator:
                    PontoDeAplicacaoValidators.intervaloDiasEntreAplicacoes,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            await context.read<PontoDeAplicacaoDetalheCubit>().editar(
              bairro: _bairroController.text,
              lat: double.parse(_latController.text),
              lng: double.parse(_lngController.text),
              distanciaAlertaMetros: double.parse(
                _distanciaAlertaController.text,
              ),
              intervaloDiasEntreAplicacoes: int.parse(
                _intervaloDiasController.text,
              ),
            );
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _AtribuicaoDeAplicador extends StatefulWidget {
  final PontoDeAplicacaoDetalheViewModel viewModel;

  const _AtribuicaoDeAplicador({required this.viewModel});

  @override
  State<_AtribuicaoDeAplicador> createState() =>
      _AtribuicaoDeAplicadorState();
}

class _AtribuicaoDeAplicadorState extends State<_AtribuicaoDeAplicador> {
  late Future<List<AplicadorOpcaoViewModel>> _opcoes;

  @override
  void initState() {
    super.initState();
    _opcoes = context
        .read<PontoDeAplicacaoDetalheCubit>()
        .listarAplicadoresDisponiveis();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AplicadorOpcaoViewModel>>(
      future: _opcoes,
      builder: (context, snapshot) {
        final opcoes = snapshot.data ?? const [];
        return DropdownButtonFormField<String?>(
          initialValue: widget.viewModel.aplicadorId,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Sem aplicador atribuído'),
            ),
            for (final aplicador in opcoes)
              DropdownMenuItem<String?>(
                value: aplicador.id,
                child: Text(aplicador.nome),
              ),
          ],
          onChanged: widget.viewModel.podeAtribuirAplicador
              ? (valor) => context
                    .read<PontoDeAplicacaoDetalheCubit>()
                    .atribuirAplicador(valor)
              : null,
        );
      },
    );
  }
}
