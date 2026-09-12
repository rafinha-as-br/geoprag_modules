import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/base_interstitial_screen.dart';
import '../../core/aplicador_navigator.dart';

class TelaEducativaScreen extends StatelessWidget {
  const TelaEducativaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Antes de denunciar...')),
      body: BaseInterstitialScreen(
        icon: Icons.school_outlined,
        iconColor: GeopragColors.green900,
        title: 'O que é um foco de borrachudo?',
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'O borrachudo se reproduz em água corrente, limpa e com corredeiras. Remansos ou água parada NÃO são focos de borrachudo (embora possam ser de pernilongos ou dengue).',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            const Text(
              'Uma denúncia aciona a equipe da Secretaria de Agricultura para vistoria física. O uso indevido deste canal atrasa o atendimento a áreas críticas.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: GeopragColors.statusAtrasado,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: GeopragColors.statusEmDia,
                    ),
                    title: Text(
                      'Água corrente, pedras, folhas na correnteza.',
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.cancel,
                      color: GeopragColors.statusAtrasado,
                    ),
                    title: Text(
                      'Potes com água parada, caixas d\'água destampadas, poças.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        primaryLabel: 'Entendi, avançar',
        onPrimary: () {
          AplicadorNavigatorScope.of(context).toDenunciaNova();
        },
        secondaryLabel: 'Cancelar',
        onSecondary: () {
          AplicadorNavigatorScope.of(context).back();
        },
      ),
    );
  }
}
