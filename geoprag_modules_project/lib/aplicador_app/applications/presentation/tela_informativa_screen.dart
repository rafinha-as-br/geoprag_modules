import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/base_interstitial_screen.dart';
import '../../core/aplicador_navigator.dart';

class TelaInformativaScreen extends StatelessWidget {
  const TelaInformativaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Aplicação')),
      body: BaseInterstitialScreen(
        icon: Icons.info_outline_rounded,
        iconColor: GeopragColors.blue600, // Blue for information
        title: 'Atenção',
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
          ],
        ),
        primaryLabel: 'Estou ciente, continuar',
        onPrimary: () {
          AplicadorNavigatorScope.of(context).toAplicacaoGeo();
        },
        secondaryLabel: 'Cancelar',
        onSecondary: () {
          AplicadorNavigatorScope.of(context).back();
        },
      ),
    );
  }
}
