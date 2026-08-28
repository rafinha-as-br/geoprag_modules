import 'package:flutter/material.dart';

/// Template de corpo de tela para o arquétipo "informativa/confirmação de
/// step" (ícone grande centralizado → título → explicação → botão de
/// avançar → botão de voltar/cancelar opcional), hoje repetido em
/// `tela_informativa_screen.dart` e `tela_educativa_screen.dart`.
///
/// [body] fica livre (`Widget`, não uma estrutura fixa de container) porque
/// as duas telas hoje divergem na composição do meio: uma usa um único
/// parágrafo dentro de um `Container` bordado, a outra usa dois parágrafos
/// soltos seguidos de uma lista de checklist — forçar as duas no mesmo
/// container descaracterizaria uma delas.
///
/// O botão secundário (`TextButton`) usa sempre o mesmo estilo (sem
/// negrito) — as duas telas originais divergiam nesse detalhe (uma usava
/// `fontWeight: bold`, a outra não); tratado aqui como inconsistência a
/// resolver, não como variação intencional.
///
/// O espaçamento entre [body] e o botão primário é fixo em 32 —
/// `tela_informativa_screen.dart` usava 48 antes da migração,
/// `tela_educativa_screen.dart` já usava 32; mesmo critério acima:
/// inconsistência resolvida para um valor único, não regressão visual.
///
/// `landing_screen.dart` é exceção intencional (hero image de fundo, sem
/// AppBar, por ser a porta de entrada sem contexto de navegação anterior)
/// e não é coberta por este template — não é um bug, é uma composição
/// diferente por natureza.
class BaseInterstitialScreen extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const BaseInterstitialScreen({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(icon, size: 80, color: iconColor),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          body,
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onPrimary,
            child: Text(
              primaryLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (secondaryLabel != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onSecondary,
              child: Text(
                secondaryLabel!,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
