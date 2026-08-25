import 'package:flutter/material.dart';

import '../state/acao_feedback.dart';
import '../theme/geoprag_colors.dart';

/// Exibição do [AcaoFeedback] (contrato único da GEOPRAG-77) dentro do corpo
/// da tela, colorida por sucesso/erro sem inspecionar a mensagem.
///
/// É um aviso embutido, não um `SnackBar`: os templates deste pacote
/// (`BaseListScreen`, `BaseFormScreen`) são `StatelessWidget` dirigidos por
/// um controller, e disparar um `SnackBar` exigiria estado de widget só para
/// lembrar qual feedback já foi mostrado. Como aviso embutido, o feedback é
/// só mais um dado do controller.
class BaseScreenFeedback extends StatelessWidget {
  final AcaoFeedback feedback;

  const BaseScreenFeedback({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    final color = switch (feedback) {
      AcaoFeedbackSucesso() => GeopragColors.statusEmDia,
      AcaoFeedbackErro() => GeopragColors.statusAtrasado,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(feedback.mensagem, style: TextStyle(color: color)),
    );
  }
}
