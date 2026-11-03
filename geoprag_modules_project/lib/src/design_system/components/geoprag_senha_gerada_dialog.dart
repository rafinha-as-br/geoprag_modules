import 'package:flutter/material.dart';

/// Dialog modal exibindo a senha inicial gerada automaticamente para um
/// novo cadastro (Administrador/Sub-Administrador — GEOPRAG-68 — ou
/// Aplicador — GEOPRAG-65), extraído para reuso entre os dois formulários
/// de cadastro (feedback de revisão do PR #12/#13: o aviso de senha
/// gerada era um painel sobreposto ilegível, virou este `AlertDialog`).
///
/// `barrierDismissible: false` — só sai pelo botão "Concluir", garantindo
/// que quem cadastrou leu a senha antes de prosseguir. A senha não fica
/// acessível em nenhum outro lugar depois que o dialog é fechado.
class GeopragSenhaGeradaDialog extends StatelessWidget {
  final String senha;
  final VoidCallback onConcluir;

  const GeopragSenhaGeradaDialog({
    super.key,
    required this.senha,
    required this.onConcluir,
  });

  /// Mostra o dialog e, ao concluir, fecha-o antes de chamar [onConcluir] —
  /// o chamador não precisa se preocupar em dar `Navigator.pop` antes de
  /// navegar (ex.: de volta ao dashboard correspondente).
  static Future<void> mostrar(
    BuildContext context, {
    required String senha,
    required VoidCallback onConcluir,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => GeopragSenhaGeradaDialog(
        senha: senha,
        onConcluir: () {
          Navigator.of(dialogContext).pop();
          onConcluir();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Senha inicial gerada'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Repasse verbalmente e pessoalmente ao novo usuário. Esta '
            'senha não será exibida novamente.',
          ),
          const SizedBox(height: 16),
          SelectableText(
            senha,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: onConcluir, child: const Text('Concluir')),
      ],
    );
  }
}
