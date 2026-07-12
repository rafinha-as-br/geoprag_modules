import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_colors.dart';

class VisualizacaoSaidaScreen extends StatelessWidget {
  const VisualizacaoSaidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha de Distribuição'),
      ),
      body: Center(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(32.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Comprovante de Saída', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.print), onPressed: () {}),
                    ],
                  ),
                  const Divider(height: 32),
                  const ListTile(
                    title: Text('Data da Entrega', style: TextStyle(color: Colors.grey)),
                    subtitle: Text('05/07/2026', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const ListTile(
                    title: Text('Produto / Lote', style: TextStyle(color: Colors.grey)),
                    subtitle: Text('BTI Líquido - Lote BTI-001', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const ListTile(
                    title: Text('Quantidade', style: TextStyle(color: Colors.grey)),
                    subtitle: Text('10 Litros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const ListTile(
                    title: Text('Responsável pelo Recebimento', style: TextStyle(color: Colors.grey)),
                    subtitle: Text('João Silva (Belchior Alto)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const ListTile(
                    title: Text('Status de Confirmação', style: TextStyle(color: Colors.grey)),
                    subtitle: Text('Aguardando aceite no app mobile', style: TextStyle(color: GeopragColors.statusDenuncia, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 32),
                  const Text('Nota: Este documento de saída permite edição apenas em campos não-críticos e não pode ser excluído.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar Registro'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
