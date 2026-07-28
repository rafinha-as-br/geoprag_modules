import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/geoprag_countdown.dart';
import '../../../src/widgets/geoprag_otp_input.dart';
import '../core/admin_navigator.dart';

/// Tela 3 · Fluxo B (Sub-Administrador) — verificação do código de 6
/// dígitos, liberado após a autorização do Administrador principal, com
/// janela de 15 minutos e uma segunda tentativa (que exige nova
/// autorização) antes do bloqueio de 24 horas.
class VerificarCodigoSubAdminScreen extends StatefulWidget {
  const VerificarCodigoSubAdminScreen({super.key});

  @override
  State<VerificarCodigoSubAdminScreen> createState() =>
      _VerificarCodigoSubAdminScreenState();
}

class _VerificarCodigoSubAdminScreenState
    extends State<VerificarCodigoSubAdminScreen> {
  static const _duracao = Duration(minutes: 15);

  bool _expirado = false;
  String _codigo = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Verifique seu e-mail',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: GeopragColors.green900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Autorizado pelo Administrador. Código enviado.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                GeopragOtpInput(
                  enabled: !_expirado,
                  onCompleted: (code) => setState(() => _codigo = code),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _expirado
                      ? Text(
                          'Código expirado. Solicite uma nova autorização ao Administrador principal.',
                          style: TextStyle(
                            color: GeopragColors.statusAtrasado,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        )
                      : GeopragCountdown(
                          duration: _duracao,
                          onExpired: () => setState(() => _expirado = true),
                        ),
                ),
                const SizedBox(height: 24),
                if (_expirado)
                  OutlinedButton(
                    onPressed: () => AdminNavigatorScope.of(
                      context,
                    ).toAguardandoAutorizacao(),
                    child: const Text('Solicitar nova redefinição'),
                  )
                else
                  ElevatedButton(
                    onPressed: _codigo.length == 6
                        ? () => AdminNavigatorScope.of(context).toRecriarSenha()
                        : null,
                    child: const Text('Confirmar código'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
