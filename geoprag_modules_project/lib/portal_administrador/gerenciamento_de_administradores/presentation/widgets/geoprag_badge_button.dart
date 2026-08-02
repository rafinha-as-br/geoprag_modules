import 'package:flutter/material.dart';

/// Botão com um indicador numérico sobreposto (badge), usado para ações que
/// levam a uma lista com itens pendentes — extraído do botão de
/// Solicitações de Promoção para reuso por outros botões desse tipo no
/// Portal Administrador (feedback de revisão do PR #9: "este é um tipo de
/// botão único mas que deve ser reutilizável").
///
/// O badge só aparece quando [badgeCount] é maior que zero.
class GeopragBadgeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int badgeCount;
  final VoidCallback onPressed;

  const GeopragBadgeButton({
    super.key,
    required this.icon,
    required this.label,
    required this.badgeCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
        ),
        if (badgeCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Text(
                '$badgeCount',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}
