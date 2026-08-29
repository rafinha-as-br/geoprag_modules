import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/widgets/base_list_screen.dart';
import '../../autenticacao/core/admin_navigator.dart';
import 'produto_view_model.dart';
import 'produtos_cubit.dart';

class CadastroProdutoScreen extends StatelessWidget {
  const CadastroProdutoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Entrada de Produto')),
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
                      'Dados do Produto e Lote',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<
                      ProdutosCubit,
                      BaseListScreenModel<ProdutoResumoViewModel>
                    >(
                      builder: (context, model) {
                        final licitacoes = model.items
                            .map((produto) => produto.licitacao)
                            .toSet()
                            .toList();
                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Licitação Vinculada',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            for (final licitacao in licitacoes)
                              DropdownMenuItem(
                                value: licitacao,
                                child: Text(licitacao),
                              ),
                          ],
                          onChanged: (v) {},
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Descrição Comercial do Produto',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Nº do Lote',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Validade',
                              suffixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Quantidade Recebida',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Unidade de Medida',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Litros',
                                child: Text('Litros (L)'),
                              ),
                              DropdownMenuItem(
                                value: 'Kg',
                                child: Text('Quilogramas (Kg)'),
                              ),
                            ],
                            onChanged: (v) {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        // GEOPRAG-72: rota alcançada por pushReplacement
                        // (destino de topo, não sub-rota) — não há frame
                        // anterior para `.back()`.
                        AdminNavigatorScope.of(context).toEstoque();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: const Text('Confirmar Entrada no Estoque'),
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
