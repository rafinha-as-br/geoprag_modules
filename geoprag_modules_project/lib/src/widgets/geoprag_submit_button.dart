import 'package:flutter/material.dart';

/// Botão de ação assíncrona com spinner, conforme o padrão repetido em todas
/// as telas de autenticação (login, esqueci senha, recriar senha). Alterna
/// automaticamente entre o texto de [label] e um spinner (20x20,
/// `strokeWidth: 2`, branco) enquanto [isLoading] é `true`, desabilitando o
/// botão nesse período. Use [style] e [labelStyle] para reproduzir variações
/// visuais entre telas (ex.: padding maior e fonte 18 no portal do
/// administrador).
class GeopragSubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final TextStyle? labelStyle;

  const GeopragSubmitButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.style,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(label, style: labelStyle),
    );
  }
}
