import 'package:flutter/material.dart';

/// Botão de voltar ("←") do `leading` de telas de detalhe/visualização e de
/// listagem intermediária (GEOPRAG-151): chama [onBack] em vez do
/// `Navigator.pop()` padrão do [BackButton] — as rotas pós-login do Portal
/// Administrador usam pilha plana (`pushReplacement`, GEOPRAG-72), então não
/// há frame anterior para popar; o destino é sempre explícito por rota.
class GeopragBackButton extends StatelessWidget {
  const GeopragBackButton({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const BackButtonIcon(),
      tooltip: 'Voltar',
      onPressed: onBack,
    );
  }
}
