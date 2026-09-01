import 'package:flutter/material.dart';

/// Uma linha de informação (rótulo + valor) dentro de um [GeopragDetailDialog].
///
/// Por padrão exibe [valor] como texto simples; passe [valorWidget] (ex.:
/// [GeopragMaskedText]) para customizar como o valor é renderizado, mantendo
/// o mesmo layout de rótulo + conteúdo.
class GeopragInfoRow extends StatelessWidget {
  final String label;
  final String valor;
  final Widget? valorWidget;

  const GeopragInfoRow({
    super.key,
    required this.label,
    required this.valor,
    this.valorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child:
                valorWidget ??
                Text(
                  valor,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
          ),
        ],
      ),
    );
  }
}

/// Dialog genérico de detalhes de um cadastro: título + subtítulo, badge de
/// status opcional, banner de aviso opcional, lista de informações
/// ([GeopragInfoRow] ou qualquer outro widget) e ações — extraído do dialog
/// de detalhes do Administrador para reuso por outros módulos que precisem
/// do mesmo padrão de "clicar na linha da tabela abre um dialog com os
/// dados e ações do cadastro" (feedback de revisão do PR #9).
///
/// Sempre inclui um botão "Fechar" antes das [actions] informadas.
class GeopragDetailDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? statusBadge;
  final Widget? banner;
  final List<Widget> infoRows;
  final List<Widget> actions;

  const GeopragDetailDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.statusBadge,
    this.banner,
    required this.infoRows,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (statusBadge != null) statusBadge!,
                ],
              ),
              if (banner != null) ...[const SizedBox(height: 16), banner!],
              const SizedBox(height: 24),
              const Divider(),
              ...infoRows,
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fechar'),
                  ),
                  ...actions,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
