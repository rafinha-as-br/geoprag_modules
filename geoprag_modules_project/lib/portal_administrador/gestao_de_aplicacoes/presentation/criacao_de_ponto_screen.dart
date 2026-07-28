import 'package:flutter/material.dart';

import '../../core/admin_navigator.dart';
// Mesmo acoplamento novo já registrado em visualizacao_de_aplicacao_screen.dart.
import '../../applicators_management/data/mock_applicators.dart';
import '../core/ponto_de_aplicacao.dart';

class CriacaoDePontoScreen extends StatelessWidget {
  const CriacaoDePontoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final aplicadoresAtivos = mockApplicators
        .where((a) => a.status == 'ativo')
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Novo Ponto de Aplicação')),
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
                      'Dados do Ponto de Aplicação',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Bairro',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Ponto criado sempre como "planejada" e sem aplicador
                    // obrigatório — atribuição pode ficar para depois.
                    DropdownButtonFormField<String?>(
                      initialValue: null,
                      decoration: const InputDecoration(
                        labelText: 'Aplicador (opcional)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Sem aplicador atribuído'),
                        ),
                        for (final aplicador in aplicadoresAtivos)
                          DropdownMenuItem<String?>(
                            value: aplicador.id,
                            child: Text(aplicador.name),
                          ),
                      ],
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<StatusPontoDeAplicacao>(
                      initialValue: StatusPontoDeAplicacao.planejada,
                      decoration: const InputDecoration(
                        labelText: 'Status Inicial',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final status in StatusPontoDeAplicacao.values)
                          DropdownMenuItem(
                            value: status,
                            child: Text(status.defaultLabel),
                          ),
                      ],
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        AdminNavigatorScope.of(context).back();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: const Text('Criar Ponto de Aplicação'),
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
