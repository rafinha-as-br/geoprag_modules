import 'package:flutter/material.dart';

import '../../autenticacao/core/admin_navigator.dart';

class CadastroFormulaScreen extends StatelessWidget {
  const CadastroFormulaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fórmula de Dosagem (Fabricante)')),
      body: Center(
        child: Container(
          width: 700,
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
                      'Configuração Base de Dosagem',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Esta fórmula/tabela é repassada à API para calcular a dosagem exata com base na Vazão (Largura x Profundidade x Velocidade) do córrego.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Fator de Conversão BTI (ml por m³/s)',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: '1.5',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Distância de Carreamento Esperada (m)',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: '150',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Fator de Correção (Água Suja/Orgânica)',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: '1.2',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Tabela Fixa (Opcional, se o fabricante não usar fórmula linear)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Para vazões predefinidas, você pode mapear valores fixos. (Interface de tabela omitida no MVP).',
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        AdminNavigatorScope.of(context).back();
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar Nova Fórmula e Atualizar API'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
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
