import 'package:flutter/material.dart';

import '../theme/geoprag_colors.dart';

/// Painel de log (lista de eventos com bullet "• "), extraído de
/// `dashboard_geral_screen.dart`. Usa `Expanded` internamente para a lista
/// ocupar o espaço restante do card — por isso precisa estar em um
/// ancestral de altura limitada (ex.: dentro de outro `Expanded`), do
/// mesmo jeito que já era exigido antes da extração.
class GeopragLogPanel extends StatelessWidget {
  final String title;
  final List<String> logs;
  final IconData icon;

  const GeopragLogPanel({
    super.key,
    required this.title,
    required this.logs,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: GeopragColors.green900),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            logs[index],
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
