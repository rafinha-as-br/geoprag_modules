import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/geoprag_countdown.dart';
import '../../../src/widgets/geoprag_otp_input.dart';
import '../../core/admin_navigator.dart';

/// Tela 2 · Fluxo C (Administrador principal) — verificação do código de 6
/// dígitos combinada com CPF, sem autorização de terceiros, dentro da
/// janela de 15 minutos (política de recuperação de senha para
/// Administradores e sub-Administradores).
class VerificarCodigoAdminScreen extends StatefulWidget {
  const VerificarCodigoAdminScreen({super.key});

  @override
  State<VerificarCodigoAdminScreen> createState() =>
      _VerificarCodigoAdminScreenState();
}

class _VerificarCodigoAdminScreenState
    extends State<VerificarCodigoAdminScreen> {
  static const _duracao = Duration(minutes: 15);

  final _cpfController = TextEditingController();
  bool _expirado = false;
  String _codigo = '';

  @override
  void dispose() {
    _cpfController.dispose();
    super.dispose();
  }

  bool get _podeConfirmar =>
      _codigo.length == 6 && _cpfController.text.length == 14;

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
                  'Confirme sua identidade',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: GeopragColors.green900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Verificação por e-mail + CPF, sem autorização de terceiros.',
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
                          'Código expirado.',
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
                const SizedBox(height: 20),
                TextFormField(
                  controller: _cpfController,
                  enabled: !_expirado,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _CpfInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: '000.000.000-00',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
                if (_expirado)
                  OutlinedButton(
                    onPressed: () =>
                        AdminNavigatorScope.of(context).toEsqueciSenha(),
                    child: const Text('Reiniciar solicitação'),
                  )
                else
                  ElevatedButton(
                    onPressed: _podeConfirmar
                        ? () => AdminNavigatorScope.of(context).toRecriarSenha()
                        : null,
                    child: const Text('Confirmar'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.substring(
      0,
      newValue.text.length.clamp(0, 11),
    );
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if (i == 2 || i == 5) buffer.write('.');
      if (i == 8) buffer.write('-');
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
