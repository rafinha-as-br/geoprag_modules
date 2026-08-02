import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../autenticacao/core/admin_navigator.dart';
import 'cadastro_saida_cubit.dart';
import 'cadastro_saida_state.dart';

class CadastroSaidaScreen extends StatefulWidget {
  const CadastroSaidaScreen({super.key});

  @override
  State<CadastroSaidaScreen> createState() => _CadastroSaidaScreenState();
}

class _CadastroSaidaScreenState extends State<CadastroSaidaScreen> {
  final _quantidadeController = TextEditingController();
  final _dataController = TextEditingController(text: '05/07/2026');

  String? _produtoIdSelecionado;
  String? _responsavelIdSelecionado;

  @override
  void dispose() {
    _quantidadeController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Nova Saída')),
      body: Center(
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Ficha de Distribuição',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<CadastroSaidaCubit, CadastroSaidaState>(
                      builder: (context, state) {
                        return switch (state) {
                          CadastroSaidaLoading() => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          CadastroSaidaError(:final message) => Text(
                            'Não foi possível carregar as opções do formulário: $message',
                          ),
                          CadastroSaidaLoaded(
                            :final produtos,
                            :final responsaveis,
                          ) =>
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                DropdownButtonFormField<String>(
                                  initialValue: _produtoIdSelecionado,
                                  decoration: const InputDecoration(
                                    labelText: 'Produto/Lote',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: [
                                    for (final produto in produtos)
                                      DropdownMenuItem(
                                        value: produto.id,
                                        child: Text(produto.nomeExibicao),
                                      ),
                                  ],
                                  onChanged: (valor) {
                                    setState(() {
                                      _produtoIdSelecionado = valor;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  initialValue: _responsavelIdSelecionado,
                                  decoration: const InputDecoration(
                                    labelText: 'Responsável pelo Recebimento',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: [
                                    for (final responsavel in responsaveis)
                                      DropdownMenuItem(
                                        value: responsavel.id,
                                        child: Text(
                                          '${responsavel.nome} - ${responsavel.bairro}',
                                        ),
                                      ),
                                  ],
                                  onChanged: (valor) {
                                    setState(() {
                                      _responsavelIdSelecionado = valor;
                                    });
                                  },
                                ),
                              ],
                            ),
                        };
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantidadeController,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                        suffixText: 'Litros/Kg',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dataController,
                      decoration: const InputDecoration(
                        labelText: 'Data da Entrega',
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        // TODO(GEOPRAG-24): submeter o formulário ao backend
                        // assim que o endpoint de criação de distribuição
                        // existir; hoje apenas retorna à listagem.
                        AdminNavigatorScope.of(context).back();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: const Text('Confirmar Saída e Gerar Documento'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
