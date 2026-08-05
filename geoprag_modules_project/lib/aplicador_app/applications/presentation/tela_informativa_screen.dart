import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../core/aplicador_navigator.dart';

class TelaInformativaScreen extends StatelessWidget {
  const TelaInformativaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Aplicação')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 80,
              color: GeopragColors.blue600, // Blue for information
            ),
            const SizedBox(height: 24),
            const Text(
              'Atenção',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GeopragColors.blue600.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: GeopragColors.blue600.withOpacity(0.3),
                ),
              ),
              child: const Text(
                'O registro da aplicação é um processo sério e não pode ser desfeito ou editado após a confirmação.\n\n'
                'Este registro gera a prova de auditoria para a Secretaria de Agricultura de que o produto biológico foi efetivamente utilizado no combate ao borrachudo no seu ponto de aplicação.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Por favor, inicie o processo apenas quando estiver fisicamente no local de aplicação e pronto para despejar o produto.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                AplicadorNavigatorScope.of(context).toAplicacaoGeo();
              },
              child: const Text(
                'Estou ciente, continuar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                AplicadorNavigatorScope.of(context).back();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
