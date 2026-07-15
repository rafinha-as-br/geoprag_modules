import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/geoprag_status_badge.dart';

/// Tela 2 · Fluxo B (Sub-Administrador) — aguardando autorização do
/// Administrador principal, notificado por e-mail e painel, conforme
/// política de recuperação de senha para Administradores e
/// sub-Administradores.
class AguardandoAutorizacaoScreen extends StatelessWidget {
  const AguardandoAutorizacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hourglass_top_outlined, size: 64, color: GeopragColors.green900),
                const SizedBox(height: 24),
                const Text(
                  'Aguardando autorização',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: GeopragColors.green900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Administrador principal notificado por e-mail e painel.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const GeopragStatusBadge(status: GeopragStatus.denuncia, label: 'Pendente'),
                const SizedBox(height: 40),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/senha/autorizar'),
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  label: const Text('Ver painel do Administrador principal (Mock)'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar solicitação'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
