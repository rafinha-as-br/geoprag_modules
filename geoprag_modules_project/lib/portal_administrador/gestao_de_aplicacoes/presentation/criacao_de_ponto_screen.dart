import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../autenticacao/core/admin_navigator.dart';
import 'criar_ponto_cubit.dart';
import 'criar_ponto_state.dart';
import 'view_models/aplicador_opcao_view_model.dart';

class CriacaoDePontoScreen extends StatefulWidget {
  const CriacaoDePontoScreen({super.key});

  @override
  State<CriacaoDePontoScreen> createState() => _CriacaoDePontoScreenState();
}

class _CriacaoDePontoScreenState extends State<CriacaoDePontoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bairroController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  String? _aplicadorIdSelecionado;
  late Future<List<AplicadorOpcaoViewModel>> _opcoesDeAplicador;

  @override
  void initState() {
    super.initState();
    _opcoesDeAplicador = context
        .read<CriarPontoCubit>()
        .listarAplicadoresDisponiveis();
  }

  @override
  void dispose() {
    _bairroController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Ponto de Aplicação')),
      body: BlocConsumer<CriarPontoCubit, CriarPontoState>(
        listener: (context, state) {
          if (state is CriarPontoSucesso) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Ponto criado em ${state.ponto.bairro}.',
                ),
              ),
            );
            // Volta para o dashboard geral, não para a visualização de um
            // bairro específico — a rota de bairro ainda usa um bairro fixo
            // (ver TODO em PontoDeAplicacaoDetalheCubit/main.dart), que
            // poderia não ser o bairro do ponto recém-criado.
            AdminNavigatorScope.of(context).toAplicacoes();
          } else if (state is CriarPontoErro) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final salvando = state is CriarPontoSalvando;
          return Center(
            child: Container(
              width: 600,
              padding: const EdgeInsets.all(32.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Dados do Ponto de Aplicação',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _bairroController,
                          decoration: const InputDecoration(
                            labelText: 'Bairro',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Informe o bairro.'
                              : null,
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
                                validator: _validarCoordenada,
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
                                validator: _validarCoordenada,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Ponto criado sempre como "planejada" e sem
                        // aplicador obrigatório — atribuição pode ficar
                        // para depois.
                        FutureBuilder<List<AplicadorOpcaoViewModel>>(
                          future: _opcoesDeAplicador,
                          builder: (context, snapshot) {
                            final opcoes = snapshot.data ?? const [];
                            return DropdownButtonFormField<String?>(
                              initialValue: _aplicadorIdSelecionado,
                              decoration: const InputDecoration(
                                labelText: 'Aplicador (opcional)',
                                border: OutlineInputBorder(),
                              ),
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
                              onChanged: (valor) => setState(() {
                                _aplicadorIdSelecionado = valor;
                              }),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: salvando
                              ? null
                              : () {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }
                                  context.read<CriarPontoCubit>().submit(
                                    bairro: _bairroController.text,
                                    lat: double.parse(_latController.text),
                                    lng: double.parse(_lngController.text),
                                    aplicadorId: _aplicadorIdSelecionado,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: salvando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Criar Ponto de Aplicação'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String? _validarCoordenada(String? value) {
    if (value == null || value.isEmpty) return 'Informe a coordenada.';
    return double.tryParse(value) == null ? 'Coordenada inválida.' : null;
  }
}
